#[path = "../../../../../crates/neo-fold/tests/common/setup.rs"]
mod common_setup;

#[allow(dead_code)]
#[path = "../neo_fold_artifacts.rs"]
mod neo_fold_artifacts;
#[path = "../neo_fold_sessions.rs"]
mod neo_fold_sessions;

fn main() {
    neo_fold_sessions::export_neo_fold_sessions();
}
