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
