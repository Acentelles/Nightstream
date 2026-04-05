//! Owns explicit transcript logging for the RV64IM parity slice.

use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeField64;
use serde::{Deserialize, Serialize};

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
