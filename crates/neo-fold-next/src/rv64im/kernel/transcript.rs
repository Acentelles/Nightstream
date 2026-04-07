//! Owns explicit transcript logging for the RV64IM parity slice.

use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeField64;
use serde::{Deserialize, Serialize};

use crate::rv64im::ccs::{
    RV64IM_PARITY_INITIAL_MEMORY_LABEL, RV64IM_PARITY_INITIAL_REGS_LABEL, RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL,
    RV64IM_PARITY_STAGE1_MIX_LABEL, RV64IM_PARITY_STAGE2_RAM_MIX_LABEL, RV64IM_PARITY_STAGE2_REG_MIX_LABEL,
    RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL, RV64IM_PARITY_TRANSCRIPT_APP_LABEL,
};
use crate::rv64im::isa::MemoryWord;
use crate::rv64im::layout::RV64_REGISTER_COUNT;

use super::simple::SimpleKernelError;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptCursorSnapshot {
    pub state_words: [u64; 8],
    pub absorbed: usize,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum TranscriptEventKind {
    AppendMessage,
    AppendU64s,
    ChallengeField,
    Digest32,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptEventRecord {
    pub kind: TranscriptEventKind,
    pub label: Vec<u8>,
    pub message: Vec<u8>,
    pub u64s: Vec<u64>,
    pub cursor_before: TranscriptCursorSnapshot,
    pub cursor_after: TranscriptCursorSnapshot,
    pub challenge_output: Option<u64>,
    pub digest_output: Option<[u8; 32]>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptRecord {
    pub app_label: Vec<u8>,
    pub events: Vec<TranscriptEventRecord>,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptChallenges {
    pub stage1_mix: u64,
    pub stage2_reg_mix: u64,
    pub stage2_ram_mix: u64,
    pub stage3_continuity_mix: u64,
    pub kernel_final_mix: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptInitialState {
    pub registers: [u64; RV64_REGISTER_COUNT],
    pub memory: Vec<MemoryWord>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct VerifiedTranscriptSurface {
    pub initial_state: TranscriptInitialState,
    pub challenges: TranscriptChallenges,
    pub final_digest: [u8; 32],
    pub event_count: usize,
    pub digest: [u8; 32],
}

fn append_bytes(tr: &mut Poseidon2Transcript, len_label: &'static [u8], value_label: &'static [u8], bytes: &[u8]) {
    tr.append_u64s(len_label, &[bytes.len() as u64]);
    tr.append_message(value_label, bytes);
}

fn append_cursor_snapshot(tr: &mut Poseidon2Transcript, prefix: &'static [u8], snapshot: &TranscriptCursorSnapshot) {
    let (state_label, absorbed_label): (&'static [u8], &'static [u8]) =
        if prefix == b"rv64im/transcript_record/event/cursor_before" {
            (
                b"rv64im/transcript_record/event/cursor_before/state",
                b"rv64im/transcript_record/event/cursor_before/absorbed",
            )
        } else {
            (
                b"rv64im/transcript_record/event/cursor_after/state",
                b"rv64im/transcript_record/event/cursor_after/absorbed",
            )
        };
    tr.append_u64s(state_label, &snapshot.state_words);
    tr.append_u64s(absorbed_label, &[snapshot.absorbed as u64]);
}

impl TranscriptRecord {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/transcript_record");
        append_bytes(
            &mut tr,
            b"rv64im/transcript_record/app_label_len",
            b"rv64im/transcript_record/app_label",
            &self.app_label,
        );
        tr.append_u64s(b"rv64im/transcript_record/event_count", &[self.events.len() as u64]);
        for event in &self.events {
            let kind = match event.kind {
                TranscriptEventKind::AppendMessage => 0u64,
                TranscriptEventKind::AppendU64s => 1u64,
                TranscriptEventKind::ChallengeField => 2u64,
                TranscriptEventKind::Digest32 => 3u64,
            };
            tr.append_u64s(b"rv64im/transcript_record/event/kind", &[kind]);
            append_bytes(
                &mut tr,
                b"rv64im/transcript_record/event/label_len",
                b"rv64im/transcript_record/event/label",
                &event.label,
            );
            append_bytes(
                &mut tr,
                b"rv64im/transcript_record/event/message_len",
                b"rv64im/transcript_record/event/message",
                &event.message,
            );
            tr.append_u64s(b"rv64im/transcript_record/event/u64_count", &[event.u64s.len() as u64]);
            if !event.u64s.is_empty() {
                tr.append_u64s(b"rv64im/transcript_record/event/u64s", &event.u64s);
            }
            append_cursor_snapshot(
                &mut tr,
                b"rv64im/transcript_record/event/cursor_before",
                &event.cursor_before,
            );
            append_cursor_snapshot(
                &mut tr,
                b"rv64im/transcript_record/event/cursor_after",
                &event.cursor_after,
            );
            match event.challenge_output {
                Some(challenge) => {
                    tr.append_u64s(b"rv64im/transcript_record/event/has_challenge", &[1]);
                    tr.append_u64s(b"rv64im/transcript_record/event/challenge", &[challenge]);
                }
                None => tr.append_u64s(b"rv64im/transcript_record/event/has_challenge", &[0]),
            }
            match event.digest_output {
                Some(digest) => {
                    tr.append_u64s(b"rv64im/transcript_record/event/has_digest", &[1]);
                    append_bytes(
                        &mut tr,
                        b"rv64im/transcript_record/event/digest_len",
                        b"rv64im/transcript_record/event/digest",
                        &digest,
                    );
                }
                None => tr.append_u64s(b"rv64im/transcript_record/event/has_digest", &[0]),
            }
        }
        tr.digest32()
    }
}

impl TranscriptInitialState {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/transcript_initial_state");
        tr.append_u64s(b"rv64im/transcript_initial_state/registers", &self.registers);
        tr.append_u64s(
            b"rv64im/transcript_initial_state/memory_len",
            &[self.memory.len() as u64],
        );
        for word in &self.memory {
            tr.append_u64s(b"rv64im/transcript_initial_state/memory_word", &[word.addr, word.value]);
        }
        tr.digest32()
    }
}

impl VerifiedTranscriptSurface {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/verified_transcript_surface");
        tr.append_message(
            b"rv64im/verified_transcript_surface/initial_state",
            &self.initial_state.expected_digest(),
        );
        tr.append_u64s(
            b"rv64im/verified_transcript_surface/challenges",
            &[
                self.challenges.stage1_mix,
                self.challenges.stage2_reg_mix,
                self.challenges.stage2_ram_mix,
                self.challenges.stage3_continuity_mix,
                self.challenges.kernel_final_mix,
            ],
        );
        tr.append_message(b"rv64im/verified_transcript_surface/final_digest", &self.final_digest);
        tr.append_u64s(
            b"rv64im/verified_transcript_surface/event_count",
            &[self.event_count as u64],
        );
        tr.digest32()
    }
}

fn leak_label(bytes: &[u8]) -> &'static [u8] {
    Box::leak(bytes.to_vec().into_boxed_slice())
}

pub(crate) fn verify_transcript_record(
    record: &TranscriptRecord,
) -> Result<VerifiedTranscriptSurface, SimpleKernelError> {
    if record.app_label.as_slice() != RV64IM_PARITY_TRANSCRIPT_APP_LABEL {
        return Err(SimpleKernelError::Bridge(
            "RV64IM transcript replay saw an unexpected app label".into(),
        ));
    }
    let mut tr = Poseidon2Transcript::new(RV64IM_PARITY_TRANSCRIPT_APP_LABEL);
    let mut challenges = TranscriptChallenges::default();
    let mut saw_stage1_mix = false;
    let mut saw_stage2_reg_mix = false;
    let mut saw_stage2_ram_mix = false;
    let mut saw_stage3_continuity_mix = false;
    let mut saw_kernel_final_mix = false;
    let mut initial_registers = None;
    let mut initial_memory = None;
    let mut final_digest = None;
    for event in &record.events {
        let cursor_before = TranscriptCursorSnapshot {
            state_words: tr.state().map(|value| value.as_canonical_u64()),
            absorbed: tr.absorbed(),
        };
        if cursor_before != event.cursor_before {
            return Err(SimpleKernelError::Bridge(
                "RV64IM transcript replay cursor-before mismatch".into(),
            ));
        }
        match event.kind {
            TranscriptEventKind::AppendMessage => tr.append_message(leak_label(&event.label), &event.message),
            TranscriptEventKind::AppendU64s => {
                tr.append_u64s(leak_label(&event.label), &event.u64s);
                if event.label.as_slice() == RV64IM_PARITY_INITIAL_REGS_LABEL {
                    if initial_registers.is_some() {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate initial register events".into(),
                        ));
                    }
                    if event.u64s.len() != RV64_REGISTER_COUNT {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried an unexpected initial register length".into(),
                        ));
                    }
                    let mut registers = [0u64; RV64_REGISTER_COUNT];
                    registers.copy_from_slice(&event.u64s);
                    initial_registers = Some(registers);
                } else if event.label.as_slice() == RV64IM_PARITY_INITIAL_MEMORY_LABEL {
                    if initial_memory.is_some() {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate initial memory events".into(),
                        ));
                    }
                    if event.u64s.len() % 2 != 0 {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried a malformed initial memory payload".into(),
                        ));
                    }
                    initial_memory = Some(
                        event
                            .u64s
                            .chunks_exact(2)
                            .map(|chunk| MemoryWord {
                                addr: chunk[0],
                                value: chunk[1],
                            })
                            .collect(),
                    );
                }
            }
            TranscriptEventKind::ChallengeField => {
                let output = tr
                    .challenge_field(leak_label(&event.label))
                    .as_canonical_u64();
                if event.challenge_output != Some(output) {
                    return Err(SimpleKernelError::Bridge(
                        "RV64IM transcript replay challenge mismatch".into(),
                    ));
                }
                if event.label.as_slice() == RV64IM_PARITY_STAGE1_MIX_LABEL {
                    if saw_stage1_mix {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate stage1 mix challenges".into(),
                        ));
                    }
                    challenges.stage1_mix = output;
                    saw_stage1_mix = true;
                } else if event.label.as_slice() == RV64IM_PARITY_STAGE2_REG_MIX_LABEL {
                    if saw_stage2_reg_mix {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate stage2 register mix challenges".into(),
                        ));
                    }
                    challenges.stage2_reg_mix = output;
                    saw_stage2_reg_mix = true;
                } else if event.label.as_slice() == RV64IM_PARITY_STAGE2_RAM_MIX_LABEL {
                    if saw_stage2_ram_mix {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate stage2 RAM mix challenges".into(),
                        ));
                    }
                    challenges.stage2_ram_mix = output;
                    saw_stage2_ram_mix = true;
                } else if event.label.as_slice() == RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL {
                    if saw_stage3_continuity_mix {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate stage3 continuity mix challenges".into(),
                        ));
                    }
                    challenges.stage3_continuity_mix = output;
                    saw_stage3_continuity_mix = true;
                } else if event.label.as_slice() == RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL {
                    if saw_kernel_final_mix {
                        return Err(SimpleKernelError::Bridge(
                            "RV64IM transcript carried duplicate kernel-final mix challenges".into(),
                        ));
                    }
                    challenges.kernel_final_mix = output;
                    saw_kernel_final_mix = true;
                }
            }
            TranscriptEventKind::Digest32 => {
                let output = tr.digest32();
                if event.digest_output != Some(output) {
                    return Err(SimpleKernelError::Bridge(
                        "RV64IM transcript replay digest mismatch".into(),
                    ));
                }
                final_digest = Some(output);
            }
        }
        let cursor_after = TranscriptCursorSnapshot {
            state_words: tr.state().map(|value| value.as_canonical_u64()),
            absorbed: tr.absorbed(),
        };
        if cursor_after != event.cursor_after {
            return Err(SimpleKernelError::Bridge(
                "RV64IM transcript replay cursor-after mismatch".into(),
            ));
        }
    }
    if !saw_stage1_mix
        || !saw_stage2_reg_mix
        || !saw_stage2_ram_mix
        || !saw_stage3_continuity_mix
        || !saw_kernel_final_mix
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM transcript is missing one or more required challenge events".into(),
        ));
    }
    let initial_state = TranscriptInitialState {
        registers: initial_registers.ok_or_else(|| {
            SimpleKernelError::Bridge("RV64IM transcript is missing the initial register event".into())
        })?,
        memory: initial_memory
            .ok_or_else(|| SimpleKernelError::Bridge("RV64IM transcript is missing the initial memory event".into()))?,
    };
    let surface = VerifiedTranscriptSurface {
        initial_state,
        challenges,
        final_digest: final_digest
            .ok_or_else(|| SimpleKernelError::Bridge("RV64IM transcript is missing the final digest event".into()))?,
        event_count: record.events.len(),
        digest: [0; 32],
    };
    Ok(VerifiedTranscriptSurface {
        digest: surface.expected_digest(),
        ..surface
    })
}

pub struct LoggingTranscript {
    inner: Poseidon2Transcript,
    app_label: Vec<u8>,
    events: Vec<TranscriptEventRecord>,
}

impl LoggingTranscript {
    pub fn new(app_label: &'static [u8]) -> Self {
        Self {
            inner: Poseidon2Transcript::new(app_label),
            app_label: app_label.to_vec(),
            events: Vec::new(),
        }
    }

    fn snapshot(&self) -> TranscriptCursorSnapshot {
        TranscriptCursorSnapshot {
            state_words: self.inner.state().map(|value| value.as_canonical_u64()),
            absorbed: self.inner.absorbed(),
        }
    }

    pub fn append_message(&mut self, label: &'static [u8], message: &[u8]) {
        let before = self.snapshot();
        self.inner.append_message(label, message);
        let after = self.snapshot();
        self.events.push(TranscriptEventRecord {
            kind: TranscriptEventKind::AppendMessage,
            label: label.to_vec(),
            message: message.to_vec(),
            u64s: Vec::new(),
            cursor_before: before,
            cursor_after: after,
            challenge_output: None,
            digest_output: None,
        });
    }

    pub fn append_u64s(&mut self, label: &'static [u8], values: &[u64]) {
        let before = self.snapshot();
        self.inner.append_u64s(label, values);
        let after = self.snapshot();
        self.events.push(TranscriptEventRecord {
            kind: TranscriptEventKind::AppendU64s,
            label: label.to_vec(),
            message: Vec::new(),
            u64s: values.to_vec(),
            cursor_before: before,
            cursor_after: after,
            challenge_output: None,
            digest_output: None,
        });
    }

    pub fn challenge_field(&mut self, label: &'static [u8]) -> u64 {
        let before = self.snapshot();
        let output = self.inner.challenge_field(label).as_canonical_u64();
        let after = self.snapshot();
        self.events.push(TranscriptEventRecord {
            kind: TranscriptEventKind::ChallengeField,
            label: label.to_vec(),
            message: Vec::new(),
            u64s: Vec::new(),
            cursor_before: before,
            cursor_after: after,
            challenge_output: Some(output),
            digest_output: None,
        });
        output
    }

    pub fn digest32(&mut self) -> [u8; 32] {
        let before = self.snapshot();
        let output = self.inner.digest32();
        let after = self.snapshot();
        self.events.push(TranscriptEventRecord {
            kind: TranscriptEventKind::Digest32,
            label: Vec::new(),
            message: Vec::new(),
            u64s: Vec::new(),
            cursor_before: before,
            cursor_after: after,
            challenge_output: None,
            digest_output: Some(output),
        });
        output
    }

    pub fn finish(self) -> TranscriptRecord {
        TranscriptRecord {
            app_label: self.app_label,
            events: self.events,
        }
    }
}
