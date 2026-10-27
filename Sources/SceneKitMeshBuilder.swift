import Foundation
import SceneKit
import UIKit
import simd

public extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - Closed Catmull-Rom 3D Track Spline

public final class TrackSpline {
    public let samples: [SIMD3<Float>]
    public let tangents: [SIMD3<Float>]
    public let rights: [SIMD3<Float>]
    public let cumulativeLengths: [Float]
    public let totalLength: Float
    public let trackHalfWidth: Float = 8.2

    public init(controlPoints: [SIMD3<Float>], subdivisionsPerSegment: Int = 28) {
        let n = controlPoints.count
        var pts: [SIMD3<Float>] = []
        pts.reserveCapacity(n * subdivisionsPerSegment)

        for i in 0..<n {
            let p0 = controlPoints[(i - 1 + n) % n]
            let p1 = controlPoints[i]
            let p2 = controlPoints[(i + 1) % n]
            let p3 = controlPoints[(i + 2) % n]

            for step in 0..<subdivisionsPerSegment {
                let t = Float(step) / Float(subdivisionsPerSegment)
                let t2 = t * t
                let t3 = t2 * t
                let pos = 0.5 * (
                    (2.0 * p1) +
                    (-p0 + p2) * t +
                    (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
                    (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
                )
                pts.append(pos)
            }
        }

        self.samples = pts
        let count = pts.count
        var tans: [SIMD3<Float>] = Array(repeating: SIMD3<Float>(0, 0, 1), count: count)
        var rts: [SIMD3<Float>] = Array(repeating: SIMD3<Float>(1, 0, 0), count: count)
        var lengths: [Float] = Array(repeating: 0, count: count)
        var running: Float = 0

        let worldUp = SIMD3<Float>(0, 1, 0)
        for i in 0..<count {
            let prev = pts[(i - 1 + count) % count]
            let next = pts[(i + 1) % count]
            let diff = next - prev
            let tan = simd_normalize(simd_length(diff) > 0.0001 ? diff : SIMD3<Float>(0, 0, 1))
            tans[i] = tan
            let right = simd_normalize(simd_cross(tan, worldUp))
            rts[i] = right
            if i > 0 {
                running += simd_distance(pts[i - 1], pts[i])
                lengths[i] = running
            }
        }
        running += simd_distance(pts[count - 1], pts[0])
        self.tangents = tans
        self.rights = rts
        self.cumulativeLengths = lengths
        self.totalLength = max(1.0, running)
    }

    public func evaluate(normalizedT: Float) -> (position: SIMD3<Float>, tangent: SIMD3<Float>, right: SIMD3<Float>) {
        var wrapped = normalizedT.truncatingRemainder(dividingBy: 1.0)
        if wrapped < 0 { wrapped += 1.0 }
        let count = samples.count
        let fIdx = wrapped * Float(count)
        let i0 = Int(floor(fIdx)) % count
        let i1 = (i0 + 1) % count
        let frac = fIdx - floor(fIdx)

        let pos = simd_mix(samples[i0], samples[i1], SIMD3<Float>(repeating: frac))
        let tan = simd_normalize(simd_mix(tangents[i0], tangents[i1], SIMD3<Float>(repeating: frac)))
        let right = simd_normalize(simd_mix(rights[i0], rights[i1], SIMD3<Float>(repeating: frac)))
        return (pos, tan, right)
    }
}

// MARK: - 3D SceneKit World & Kart Builder

public enum SceneKitMeshBuilder {

    public static func buildCircuitScene(spec: CircuitSpec, spline: TrackSpline) -> (scene: SCNScene, boostPadTs: [Float], itemBoxNodes: [(node: SCNNode, t: Float, lateral: Float)]) {
        let scene = SCNScene()
        scene.background.contents = UIColor(hex: spec.skyTopHex)
        scene.fogStartDistance = 120
        scene.fogEndDistance = 340
        scene.fogColor = UIColor(hex: spec.skyBottomHex)

        // Ambient + Directional Sun Light
        let ambientNode = SCNNode()
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 620
        ambient.color = UIColor(hex: spec.skyBottomHex).withAlphaComponent(0.9)
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        let sunNode = SCNNode()
        let sun = SCNLight()
        sun.type = .directional
        sun.intensity = 1150
        sun.color = UIColor.white
        sun.castsShadow = true
        sun.shadowRadius = 4.0
        sun.shadowColor = UIColor(white: 0.0, alpha: 0.35)
        sunNode.light = sun
        sunNode.eulerAngles = SCNVector3(-Float.pi / 3.2, Float.pi / 4.0, 0)
        scene.rootNode.addChildNode(sunNode)

        // Ground Plane
        let groundGeo = SCNFloor()
        groundGeo.reflectivity = 0.06
        let groundMat = SCNMaterial()
        groundMat.lightingModel = .physicallyBased
        groundMat.diffuse.contents = UIColor(hex: spec.groundHex)
        groundMat.roughness.contents = 0.85
        groundGeo.materials = [groundMat]
        let groundNode = SCNNode(geometry: groundGeo)
        groundNode.position = SCNVector3(0, -0.5, 0)
        scene.rootNode.addChildNode(groundNode)

        // Track Asphalt Ribbon Mesh
        let roadNode = buildRoadRibbonNode(spline: spline, width: spline.trackHalfWidth * 2.0, yOffset: 0.04, color: UIColor(hex: spec.asphaltHex))
        scene.rootNode.addChildNode(roadNode)

        // Center Racing Line Stripe Ribbon
        let centerLineNode = buildRoadRibbonNode(spline: spline, width: 0.45, yOffset: 0.08, color: UIColor(hex: spec.accentHex).withAlphaComponent(0.65))
        scene.rootNode.addChildNode(centerLineNode)

        // Raised Alternating Candy Curbs & Trackside Props
        let count = spline.samples.count
        let primaryCurbMat = SCNMaterial()
        primaryCurbMat.lightingModel = .physicallyBased
        primaryCurbMat.diffuse.contents = UIColor(hex: spec.curbPrimaryHex)
        primaryCurbMat.roughness.contents = 0.35

        let secondaryCurbMat = SCNMaterial()
        secondaryCurbMat.lightingModel = .physicallyBased
        secondaryCurbMat.diffuse.contents = UIColor(hex: spec.curbSecondaryHex)
        secondaryCurbMat.roughness.contents = 0.35

        let curbGeo = SCNBox(width: 1.15, height: 0.32, length: 2.6, chamferRadius: 0.08)

        for i in stride(from: 0, to: count, by: 2) {
            let p = spline.samples[i]
            let r = spline.rights[i]
            let t = spline.tangents[i]
            let yaw = atan2(t.x, t.z)
            let isEven = (i / 2) % 2 == 0
            let mat = isEven ? primaryCurbMat : secondaryCurbMat

            for side in [-1.0 as Float, 1.0 as Float] {
                let cPos = p + r * (spline.trackHalfWidth + 0.5) * side
                let cNode = SCNNode(geometry: curbGeo.copy() as? SCNGeometry)
                cNode.geometry?.materials = [mat]
                cNode.position = SCNVector3(cPos.x, cPos.y + 0.16, cPos.z)
                cNode.eulerAngles = SCNVector3(0, yaw, 0)
                scene.rootNode.addChildNode(cNode)
            }

            // Place themed 3D roadside scenery props every 8 samples
            if i % 8 == 0 {
                let side: Float = (i % 16 == 0) ? 1.0 : -1.0
                let dist = spline.trackHalfWidth + 7.5 + Float((i * 7) % 9)
                let propPos = p + r * (dist * side)
                let propNode = buildThemedSceneryProp(circuitId: spec.id, accentHex: spec.accentHex, primaryHex: spec.curbPrimaryHex, seed: i)
                propNode.position = SCNVector3(propPos.x, propPos.y, propPos.z)
                scene.rootNode.addChildNode(propNode)
            }
        }

        // Start / Finish Gantry Arch at t = 0
        let startEval = spline.evaluate(normalizedT: 0)
        let gantryNode = buildStartGantry(spec: spec, width: spline.trackHalfWidth * 2.1)
        gantryNode.position = SCNVector3(startEval.position.x, startEval.position.y, startEval.position.z)
        gantryNode.eulerAngles = SCNVector3(0, atan2(startEval.tangent.x, startEval.tangent.z), 0)
        scene.rootNode.addChildNode(gantryNode)

        // Boost Pads (6 around the circuit)
        let boostPadTs: [Float] = [0.14, 0.29, 0.46, 0.62, 0.78, 0.91]
        for bt in boostPadTs {
            let ev = spline.evaluate(normalizedT: bt)
            let padNode = buildBoostPadNode(accentHex: spec.accentHex)
            padNode.position = SCNVector3(ev.position.x, ev.position.y + 0.10, ev.position.z)
            padNode.eulerAngles = SCNVector3(0, atan2(ev.tangent.x, ev.tangent.z), 0)
            scene.rootNode.addChildNode(padNode)
        }

        // Floating Item Crystal Boxes
        var itemBoxNodes: [(node: SCNNode, t: Float, lateral: Float)] = []
        let boxTs: [Float] = [0.20, 0.52, 0.83]
        for bt in boxTs {
            for lat in [-3.4 as Float, 0.0 as Float, 3.4 as Float] {
                let ev = spline.evaluate(normalizedT: bt)
                let pos = ev.position + ev.right * lat
                let boxNode = buildItemCrystalBox(accentHex: spec.accentHex)
                boxNode.position = SCNVector3(pos.x, pos.y + 1.25, pos.z)
                scene.rootNode.addChildNode(boxNode)
                itemBoxNodes.append((boxNode, bt, lat))
            }
        }

        return (scene, boostPadTs, itemBoxNodes)
    }

    private static func buildRoadRibbonNode(spline: TrackSpline, width: Float, yOffset: Float, color: UIColor) -> SCNNode {
        let count = spline.samples.count
        var vertices: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var indices: [Int32] = []

        let halfW = width * 0.5
        for i in 0...count {
            let idx = i % count
            let p = spline.samples[idx]
            let r = spline.rights[idx]
            let leftPt = p - r * halfW
            let rightPt = p + r * halfW
            vertices.append(SCNVector3(leftPt.x, leftPt.y + yOffset, leftPt.z))
            vertices.append(SCNVector3(rightPt.x, rightPt.y + yOffset, rightPt.z))
            normals.append(SCNVector3(0, 1, 0))
            normals.append(SCNVector3(0, 1, 0))

            if i < count {
                let base = Int32(i * 2)
                indices.append(contentsOf: [base, base + 1, base + 2, base + 1, base + 3, base + 2])
            }
        }

        let vSource = SCNGeometrySource(vertices: vertices)
        let nSource = SCNGeometrySource(normals: normals)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geo = SCNGeometry(sources: [vSource, nSource], elements: [element])

        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = color
        mat.roughness.contents = 0.55
        mat.metalness.contents = 0.12
        mat.isDoubleSided = true
        geo.materials = [mat]

        return SCNNode(geometry: geo)
    }

    private static func buildStartGantry(spec: CircuitSpec, width: Float) -> SCNNode {
        let root = SCNNode()
        let pillarGeo = SCNCylinder(radius: 0.55, height: 7.5)
        let pillarMat = SCNMaterial()
        pillarMat.lightingModel = .physicallyBased
        pillarMat.diffuse.contents = UIColor(hex: spec.curbPrimaryHex)
        pillarMat.metalness.contents = 0.6
        pillarGeo.materials = [pillarMat]

        let leftPillar = SCNNode(geometry: pillarGeo)
        leftPillar.position = SCNVector3(-width * 0.52, 3.75, 0)
        root.addChildNode(leftPillar)

        let rightPillar = SCNNode(geometry: pillarGeo)
        rightPillar.position = SCNVector3(width * 0.52, 3.75, 0)
        root.addChildNode(rightPillar)

        let bannerGeo = SCNBox(width: CGFloat(width * 1.08), height: 1.4, length: 0.7, chamferRadius: 0.15)
        let bannerMat = SCNMaterial()
        bannerMat.lightingModel = .physicallyBased
        bannerMat.diffuse.contents = UIColor(hex: spec.accentHex)
        bannerMat.emission.contents = UIColor(hex: spec.accentHex).withAlphaComponent(0.35)
        bannerGeo.materials = [bannerMat]
        let banner = SCNNode(geometry: bannerGeo)
        banner.position = SCNVector3(0, 6.8, 0)
        root.addChildNode(banner)

        return root
    }

    private static func buildBoostPadNode(accentHex: UInt32) -> SCNNode {
        let padGeo = SCNBox(width: 4.6, height: 0.08, length: 5.5, chamferRadius: 0.1)
        let padMat = SCNMaterial()
        padMat.lightingModel = .physicallyBased
        padMat.diffuse.contents = UIColor(hex: accentHex)
        padMat.emission.contents = UIColor(hex: accentHex)
        padGeo.materials = [padMat]
        return SCNNode(geometry: padGeo)
    }

    private static func buildItemCrystalBox(accentHex: UInt32) -> SCNNode {
        let boxGeo = SCNBox(width: 1.25, height: 1.25, length: 1.25, chamferRadius: 0.22)
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = UIColor(hex: accentHex).withAlphaComponent(0.88)
        mat.emission.contents = UIColor(hex: 0xF472B6).withAlphaComponent(0.45)
        mat.metalness.contents = 0.8
        mat.roughness.contents = 0.1
        boxGeo.materials = [mat]

        let node = SCNNode(geometry: boxGeo)
        let spin = SCNAction.rotateBy(x: CGFloat.pi, y: CGFloat.pi * 2, z: 0, duration: 2.6)
        node.runAction(SCNAction.repeatForever(spin))
        return node
    }

    private static func buildThemedSceneryProp(circuitId: String, accentHex: UInt32, primaryHex: UInt32, seed: Int) -> SCNNode {
        let root = SCNNode()
        let trunkGeo = SCNCylinder(radius: 0.45, height: 3.6)
        let trunkMat = SCNMaterial()
        trunkMat.diffuse.contents = UIColor.white
        trunkGeo.materials = [trunkMat]
        let trunk = SCNNode(geometry: trunkGeo)
        trunk.position = SCNVector3(0, 1.8, 0)
        root.addChildNode(trunk)

        let crownHex = (seed % 16 == 0) ? primaryHex : accentHex
        let crownMat = SCNMaterial()
        crownMat.lightingModel = .physicallyBased
        crownMat.diffuse.contents = UIColor(hex: crownHex)
        crownMat.roughness.contents = 0.25
        crownMat.metalness.contents = 0.35

        if circuitId == "canyon" || circuitId == "glacier" || circuitId == "lava" {
            let spireGeo = SCNCone(topRadius: 0.0, bottomRadius: 2.2, height: 6.2)
            spireGeo.materials = [crownMat]
            let spire = SCNNode(geometry: spireGeo)
            spire.position = SCNVector3(0, 3.1, 0)
            root.addChildNode(spire)
        } else {
            let sphereGeo = SCNSphere(radius: 2.3)
            sphereGeo.materials = [crownMat]
            let crown = SCNNode(geometry: sphereGeo)
            crown.position = SCNVector3(0, 4.4, 0)
            root.addChildNode(crown)
        }
        return root
    }

    // MARK: - Articulated 3D Kart & Critter Driver Builder

    public static func buildKartNode(driver: CritterDriverSpec, loadout: KartLoadout) -> SCNNode {
        let root = SCNNode()
        root.name = "kart_root"

        let paint = GameCatalog.paints.first(where: { $0.id == loadout.paintId }) ?? GameCatalog.paints[0]
        let rim = GameCatalog.rims.first(where: { $0.id == loadout.rimId }) ?? GameCatalog.rims[0]
        let wing = GameCatalog.wings.first(where: { $0.id == loadout.wingId }) ?? GameCatalog.wings[0]

        let bodyMat = SCNMaterial()
        bodyMat.lightingModel = .physicallyBased
        bodyMat.diffuse.contents = UIColor(hex: paint.bodyHex)
        bodyMat.metalness.contents = paint.metalness
        bodyMat.roughness.contents = paint.roughness

        let trimMat = SCNMaterial()
        trimMat.lightingModel = .physicallyBased
        trimMat.diffuse.contents = UIColor(hex: paint.trimHex)
        trimMat.metalness.contents = 0.8
        trimMat.roughness.contents = 0.2

        let chassisContainer = SCNNode()
        chassisContainer.name = "chassis_tilt"
        root.addChildNode(chassisContainer)

        // Main Lower Chassis Tub
        let tubGeo = SCNBox(width: 1.55, height: 0.36, length: 2.55, chamferRadius: 0.14)
        tubGeo.materials = [bodyMat]
        let tubNode = SCNNode(geometry: tubGeo)
        tubNode.position = SCNVector3(0, 0.36, 0)
        chassisContainer.addChildNode(tubNode)

        // Sculpted Front Nose Fairing
        let noseGeo = SCNBox(width: 1.20, height: 0.28, length: 0.95, chamferRadius: 0.12)
        noseGeo.materials = [trimMat]
        let noseNode = SCNNode(geometry: noseGeo)
        noseNode.position = SCNVector3(0, 0.34, 1.15)
        chassisContainer.addChildNode(noseNode)

        // Left & Right Sidepods
        let podGeo = SCNBox(width: 0.36, height: 0.32, length: 1.45, chamferRadius: 0.10)
        podGeo.materials = [trimMat]
        for side in [-0.82 as Float, 0.82 as Float] {
            let pod = SCNNode(geometry: podGeo)
            pod.position = SCNVector3(side, 0.36, -0.05)
            chassisContainer.addChildNode(pod)
        }

        // Custom Aero Rear Wing
        let wingMat = SCNMaterial()
        wingMat.lightingModel = .physicallyBased
        wingMat.diffuse.contents = UIColor(hex: wing.wingHex)
        wingMat.metalness.contents = 0.75
        wingMat.roughness.contents = 0.20

        let bladeWidth: CGFloat = wing.styleIndex == 1 ? 1.85 : 1.65
        let bladeGeo = SCNBox(width: bladeWidth, height: 0.08, length: 0.42, chamferRadius: 0.03)
        bladeGeo.materials = [wingMat]
        let bladeNode = SCNNode(geometry: bladeGeo)
        bladeNode.position = SCNVector3(0, 0.98, -1.15)
        chassisContainer.addChildNode(bladeNode)

        let strutGeo = SCNBox(width: 0.08, height: 0.48, length: 0.22, chamferRadius: 0.02)
        strutGeo.materials = [wingMat]
        for sx in [-0.45 as Float, 0.45 as Float] {
            let strut = SCNNode(geometry: strutGeo)
            strut.position = SCNVector3(sx, 0.74, -1.12)
            chassisContainer.addChildNode(strut)
        }

        // 4 Rotating Wheels + Custom Alloy Rims
        let tireMat = SCNMaterial()
        tireMat.lightingModel = .physicallyBased
        tireMat.diffuse.contents = UIColor(white: 0.12, alpha: 1.0)
        tireMat.roughness.contents = 0.75

        let rimMat = SCNMaterial()
        rimMat.lightingModel = .physicallyBased
        rimMat.diffuse.contents = UIColor(hex: rim.rimHex)
        rimMat.metalness.contents = 0.90
        rimMat.roughness.contents = 0.15

        let wheelPositions: [(String, Float, Float)] = [
            ("wheel_fl", -0.88, 0.88),
            ("wheel_fr", 0.88, 0.88),
            ("wheel_rl", -0.92, -0.85),
            ("wheel_rr", 0.92, -0.85)
        ]

        for (wName, wx, wz) in wheelPositions {
            let wHolder = SCNNode()
            wHolder.name = wName
            wHolder.position = SCNVector3(wx, 0.34, wz)

            let tireGeo = SCNCylinder(radius: 0.34, height: 0.32)
            tireGeo.materials = [tireMat]
            let tireNode = SCNNode(geometry: tireGeo)
            tireNode.eulerAngles = SCNVector3(0, 0, Float.pi * 0.5)
            wHolder.addChildNode(tireNode)

            let hubGeo = SCNCylinder(radius: 0.21, height: 0.34)
            hubGeo.materials = [rimMat]
            let hubNode = SCNNode(geometry: hubGeo)
            hubNode.eulerAngles = SCNVector3(0, 0, Float.pi * 0.5)
            wHolder.addChildNode(hubNode)

            root.addChildNode(wHolder)
        }

        // Dual Rear Boost Flame Cones
        let flameMat = SCNMaterial()
        flameMat.diffuse.contents = UIColor(hex: 0x38BDF8)
        flameMat.emission.contents = UIColor(hex: 0xF472B6)
        let flameGeo = SCNCone(topRadius: 0.02, bottomRadius: 0.20, height: 0.85)
        flameGeo.materials = [flameMat]

        let flameGroup = SCNNode()
        flameGroup.name = "boost_flames"
        flameGroup.isHidden = true
        for fx in [-0.36 as Float, 0.36 as Float] {
            let fNode = SCNNode(geometry: flameGeo)
            fNode.position = SCNVector3(fx, 0.45, -1.65)
            fNode.eulerAngles = SCNVector3(-Float.pi * 0.5, 0, 0)
            flameGroup.addChildNode(fNode)
        }
        chassisContainer.addChildNode(flameGroup)

        // 3D Critter Driver in Cockpit
        let driverNode = buildCritterDriverCharacter(driver: driver)
        driverNode.name = "critter_driver"
        driverNode.position = SCNVector3(0, 0.58, -0.05)
        chassisContainer.addChildNode(driverNode)

        return root
    }

    private static func buildCritterDriverCharacter(driver: CritterDriverSpec) -> SCNNode {
        let node = SCNNode()

        let primaryMat = SCNMaterial()
        primaryMat.lightingModel = .physicallyBased
        primaryMat.diffuse.contents = UIColor(hex: driver.primaryColorHex)
        primaryMat.roughness.contents = 0.35

        let secondaryMat = SCNMaterial()
        secondaryMat.lightingModel = .physicallyBased
        secondaryMat.diffuse.contents = UIColor(hex: driver.secondaryColorHex)
        secondaryMat.roughness.contents = 0.30

        // Torso
        let torsoGeo = SCNCylinder(radius: 0.30, height: 0.44)
        torsoGeo.materials = [secondaryMat]
        let torso = SCNNode(geometry: torsoGeo)
        torso.position = SCNVector3(0, 0.18, 0)
        node.addChildNode(torso)

        // Head
        let headGeo = SCNSphere(radius: 0.36)
        headGeo.materials = [primaryMat]
        let head = SCNNode(geometry: headGeo)
        head.position = SCNVector3(0, 0.62, 0.04)
        node.addChildNode(head)

        // Expressive Eyes
        let eyeMat = SCNMaterial()
        eyeMat.diffuse.contents = UIColor(white: 0.08, alpha: 1.0)
        let eyeGeo = SCNSphere(radius: 0.065)
        eyeGeo.materials = [eyeMat]
        for ex in [-0.14 as Float, 0.14 as Float] {
            let eye = SCNNode(geometry: eyeGeo)
            eye.position = SCNVector3(ex, 0.66, 0.34)
            node.addChildNode(eye)
        }

        // Character-Specific Ears / Horns / Axolotl Gills
        let earGeo = SCNCone(topRadius: 0.03, bottomRadius: 0.13, height: 0.32)
        earGeo.materials = [secondaryMat]
        for side in [-1.0 as Float, 1.0 as Float] {
            let ear = SCNNode(geometry: earGeo)
            ear.position = SCNVector3(0.24 * side, 0.96, 0.02)
            ear.eulerAngles = SCNVector3(0, 0, -0.25 * side)
            node.addChildNode(ear)
        }

        return node
    }
}
