//! Owns lightweight WASM trace normalization and identity lowering.

use rwasm::Tracer;

use super::adapters::rwasm::traces_from_rwasm_tracer;
use super::ir::{WasmBuildError, WasmStepTrace};

pub type WasmExecutionStep = WasmStepTrace;

pub trait WasmTraceSource {
    fn lower_to_wasm_ir(&self) -> Result<Vec<WasmExecutionStep>, WasmBuildError>;
}

impl WasmTraceSource for Tracer {
    fn lower_to_wasm_ir(&self) -> Result<Vec<WasmExecutionStep>, WasmBuildError> {
        traces_from_rwasm_tracer(self)
    }
}

impl WasmTraceSource for [WasmExecutionStep] {
    fn lower_to_wasm_ir(&self) -> Result<Vec<WasmExecutionStep>, WasmBuildError> {
        Ok(self.to_vec())
    }
}

impl WasmTraceSource for Vec<WasmExecutionStep> {
    fn lower_to_wasm_ir(&self) -> Result<Vec<WasmExecutionStep>, WasmBuildError> {
        Ok(self.clone())
    }
}

pub fn normalize_source(source: &impl WasmTraceSource) -> Result<Vec<WasmExecutionStep>, WasmBuildError> {
    source.lower_to_wasm_ir()
}

pub fn normalize_tracer(tracer: &Tracer) -> Result<Vec<WasmExecutionStep>, WasmBuildError> {
    normalize_source(tracer)
}

pub fn build_row_traces(steps: &[WasmExecutionStep]) -> Vec<WasmExecutionStep> {
    steps.to_vec()
}
