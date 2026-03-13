use neo_gpu::DeviceApi;

#[test]
fn auto_candidate_order_matches_supported_production_backends() {
    #[cfg(target_os = "macos")]
    assert_eq!(DeviceApi::Auto.candidate_order(), &[DeviceApi::Metal, DeviceApi::Cpu]);

    #[cfg(not(target_os = "macos"))]
    assert_eq!(DeviceApi::Auto.candidate_order(), &[DeviceApi::Cuda, DeviceApi::Cpu]);
}
