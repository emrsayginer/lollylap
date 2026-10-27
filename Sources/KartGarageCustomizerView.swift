import SwiftUI
import SceneKit
import Charts

public struct GarageTurntableSCNView: UIViewRepresentable {
    public let driver: CritterDriverSpec
    public let loadout: KartLoadout

    public init(driver: CritterDriverSpec, loadout: KartLoadout) {
        self.driver = driver
        self.loadout = loadout
    }

    public func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.backgroundColor = UIColor(hex: 0x0F172A)
        view.scene = buildShowroomScene()
        return view
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = buildShowroomScene()
    }

    private func buildShowroomScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(hex: 0x0F172A)

        // Studio Lighting
        let ambientNode = SCNNode()
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 650
        ambient.color = UIColor(hex: 0xE0E7FF)
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        let keyLightNode = SCNNode()
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 1250
        keyLight.color = UIColor.white
        keyLightNode.light = keyLight
        keyLightNode.eulerAngles = SCNVector3(-Float.pi / 3.2, Float.pi / 4.2, 0)
        scene.rootNode.addChildNode(keyLightNode)

        let rimLightNode = SCNNode()
        let rimLight = SCNLight()
        rimLight.type = .omni
        rimLight.intensity = 850
        rimLight.color = UIColor(hex: 0xF472B6)
        rimLightNode.light = rimLight
        rimLightNode.position = SCNVector3(-3.0, 2.5, -3.0)
        scene.rootNode.addChildNode(rimLightNode)

        // Showroom Turntable Pedestal
        let baseGeo = SCNCylinder(radius: 2.15, height: 0.18)
        let baseMat = SCNMaterial()
        baseMat.lightingModel = .physicallyBased
        baseMat.diffuse.contents = UIColor(hex: 0x1E293B)
        baseMat.metalness.contents = 0.85
        baseMat.roughness.contents = 0.18
        baseGeo.materials = [baseMat]

        let ringGeo = SCNTorus(ringRadius: 2.15, pipeRadius: 0.045)
        let ringMat = SCNMaterial()
        ringMat.diffuse.contents = UIColor(hex: 0x38BDF8)
        ringMat.emission.contents = UIColor(hex: 0x38BDF8)
        ringGeo.materials = [ringMat]

        let turntable = SCNNode()
        let pedestal = SCNNode(geometry: baseGeo)
        pedestal.position = SCNVector3(0, -0.09, 0)
        turntable.addChildNode(pedestal)

        let neonRing = SCNNode(geometry: ringGeo)
        neonRing.position = SCNVector3(0, 0.01, 0)
        turntable.addChildNode(neonRing)

        let kartNode = SceneKitMeshBuilder.buildKartNode(driver: driver, loadout: loadout)
        turntable.addChildNode(kartNode)

        let spin = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 14.0)
        turntable.runAction(SCNAction.repeatForever(spin))
        scene.rootNode.addChildNode(turntable)

        // Showroom Camera
        let camNode = SCNNode()
        let cam = SCNCamera()
        cam.fieldOfView = 48
        camNode.camera = cam
        camNode.position = SCNVector3(3.1, 2.05, 3.6)
        camNode.look(at: SCNVector3(0, 0.55, 0))
        scene.rootNode.addChildNode(camNode)

        return scene
    }
}

public struct DynoCurveSample: Identifiable {
    public var id: Int { step }
    public let step: Int
    public let timeSec: Double
    public let speedKmh: Double
}

public struct KartGarageCustomizerView: View {
    public let language: AppLanguage
    public let selectedDriver: CritterDriverSpec
    @Binding public var loadout: KartLoadout
    public let isVipUnlocked: Bool
    public let onOpenPaywall: () -> Void

    public init(
        language: AppLanguage,
        selectedDriver: CritterDriverSpec,
        loadout: Binding<KartLoadout>,
        isVipUnlocked: Bool,
        onOpenPaywall: @escaping () -> Void
    ) {
        self.language = language
        self.selectedDriver = selectedDriver
        self._loadout = loadout
        self.isVipUnlocked = isVipUnlocked
        self.onOpenPaywall = onOpenPaywall
    }

    private var dynoCurveSamples: [DynoCurveSample] {
        let topKmh = 132.0 + selectedDriver.baseSpeed * 28.0 + loadout.finalDriveRatio * 24.0 - loadout.aeroDownforce * 7.5
        let tau = 2.65 - selectedDriver.baseAccel * 0.55 - (1.0 - loadout.finalDriveRatio) * 0.65
        return (0...10).map { sec in
            let t = Double(sec)
            let v = topKmh * (1.0 - exp(-t / max(0.8, tau)))
            return DynoCurveSample(step: sec, timeSec: t, speedKmh: v)
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("garage.title", language))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(L10n.t("garage.subtitle", language))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.72))
                }

                // Interactive 3D Showroom + Live Dyno Chart Row
                HStack(spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        GarageTurntableSCNView(driver: selectedDriver, loadout: loadout)
                            .frame(height: 235)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.cyan.opacity(0.45), lineWidth: 1.5)
                            )

                        HStack(spacing: 6) {
                            Image(systemName: "cube.transparent.fill")
                                .foregroundColor(.cyan)
                            Text("\(selectedDriver.name) • 360° 3D")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Capsule())
                        .padding(10)
                    }

                    // Live Apple Charts Dyno Curve
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("garage.dynoChart", language))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.cyan)

                        Chart(dynoCurveSamples) { sample in
                            AreaMark(
                                x: .value("Sec", sample.timeSec),
                                y: .value("km/h", sample.speedKmh)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.45), Color.cyan.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            LineMark(
                                x: .value("Sec", sample.timeSec),
                                y: .value("km/h", sample.speedKmh)
                            )
                            .foregroundStyle(Color.pink)
                            .lineStyle(StrokeStyle(lineWidth: 3.0))
                        }
                        .chartYScale(domain: 0...190)
                        .frame(height: 185)
                    }
                    .padding(14)
                    .background(Color(red: 0.09, green: 0.12, blue: 0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: 320)
                }

                // Paint Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t("garage.paint", language))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(GameCatalog.paints.enumerated()), id: \.element.id) { idx, paint in
                                let locked = idx >= 2 && !isVipUnlocked
                                Button {
                                    HapticsAndAudioEngine.shared.playTap()
                                    if locked {
                                        onOpenPaywall()
                                    } else {
                                        loadout.paintId = paint.id
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(UIColor(hex: paint.bodyHex)))
                                            .frame(width: 20, height: 20)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                        Text(language == .tr ? paint.nameTr : paint.nameEn)
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        if locked {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 9)
                                    .background(loadout.paintId == paint.id ? Color.pink.opacity(0.35) : Color.white.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(loadout.paintId == paint.id ? Color.pink : Color.white.opacity(0.15), lineWidth: 1.5)
                                    )
                                }
                            }
                        }
                    }
                }

                // Rims & Aero Wing Row
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("garage.rims", language))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        ForEach(GameCatalog.rims) { rim in
                            Button {
                                HapticsAndAudioEngine.shared.playTap()
                                loadout.rimId = rim.id
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(Color(UIColor(hex: rim.rimHex)))
                                        .frame(width: 16, height: 16)
                                    Text(language == .tr ? rim.nameTr : rim.nameEn)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("+\(Int(rim.gripBonus * 100))% Grip")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.cyan)
                                }
                                .padding(10)
                                .background(loadout.rimId == rim.id ? Color.cyan.opacity(0.25) : Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("garage.wing", language))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        ForEach(GameCatalog.wings) { wing in
                            Button {
                                HapticsAndAudioEngine.shared.playTap()
                                loadout.wingId = wing.id
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(Color(UIColor(hex: wing.wingHex)))
                                        .frame(width: 16, height: 16)
                                    Text(language == .tr ? wing.nameTr : wing.nameEn)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("+\(Int(wing.downforceBonus * 100))% Aero")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.pink)
                                }
                                .padding(10)
                                .background(loadout.wingId == wing.id ? Color.pink.opacity(0.25) : Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                // 4-Axis Mechanical Dyno Tuning Workbench
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.t("garage.dyno", language))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)

                    dynoSliderRow(title: L10n.t("garage.gearRatio", language), value: $loadout.finalDriveRatio, tint: .pink)
                    dynoSliderRow(title: L10n.t("garage.downforce", language), value: $loadout.aeroDownforce, tint: .cyan)
                    dynoSliderRow(title: L10n.t("garage.suspension", language), value: $loadout.suspensionStiffness, tint: .green)
                    dynoSliderRow(title: L10n.t("garage.boostMix", language), value: $loadout.driftBoostMix, tint: .orange)
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(18)
        }
    }

    private func dynoSliderRow(title: String, value: Binding<Double>, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(tint)
            }
            Slider(value: value, in: 0.15...0.95)
                .tint(tint)
        }
    }
}
