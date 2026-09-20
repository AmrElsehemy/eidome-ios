import SwiftUI

private struct AnatomyKnowledgeEntry {
    enum Source {
        case upperMuscle, lowerMuscle, headMuscle, upperBone, lowerBone, axialBone

        var title: String {
            switch self {
            case .upperMuscle: "OpenStax A&P 2e §11.5"
            case .lowerMuscle: "OpenStax A&P 2e §11.6"
            case .headMuscle: "OpenStax A&P 2e §11.3"
            case .upperBone: "OpenStax A&P 2e §8.2"
            case .lowerBone: "OpenStax A&P 2e §8.4"
            case .axialBone: "OpenStax A&P 2e, Axial Skeleton"
            }
        }

        var url: URL {
            let path: String
            switch self {
            case .upperMuscle:
                path = "11-5-muscles-of-the-pectoral-girdle-and-upper-limbs"
            case .lowerMuscle:
                path = "11-6-appendicular-muscles-of-the-pelvic-girdle-and-lower-limbs"
            case .headMuscle:
                path = "11-3-axial-muscles-of-the-head-neck-and-back"
            case .upperBone:
                path = "8-2-bones-of-the-upper-limb"
            case .lowerBone:
                path = "8-4-bones-of-the-lower-limb"
            case .axialBone:
                path = "7-1-divisions-of-the-skeletal-system"
            }
            return URL(string: "https://openstax.org/books/anatomy-and-physiology-2e/pages/\(path)")!
        }
    }

    let pattern: String
    let region: String
    let function: String
    let movement: String
    let source: Source
}

private enum AnatomyKnowledge {
    // Specific names precede broader terms so multipart source meshes resolve
    // to the most precise supported explanation.
    static let entries: [AnatomyKnowledgeEntry] = [
        .init(pattern: "acromial part of deltoid", region: "Outer shoulder", function: "Raises the arm away from the body.", movement: "Shoulder abduction", source: .upperMuscle),
        .init(pattern: "clavicular part of deltoid", region: "Front of shoulder", function: "Assists raising the arm forward and turning it inward.", movement: "Shoulder flexion and medial rotation", source: .upperMuscle),
        .init(pattern: "scapular spinal part of deltoid", region: "Back of shoulder", function: "Assists moving the arm backward and turning it outward.", movement: "Shoulder extension and lateral rotation", source: .upperMuscle),
        .init(pattern: "descending part of trapezius", region: "Upper back and neck", function: "Assists elevating and upwardly rotating the shoulder blade.", movement: "Scapular elevation and upward rotation", source: .upperMuscle),
        .init(pattern: "transverse part of trapezius", region: "Upper back", function: "Draws the shoulder blade toward the spine.", movement: "Scapular retraction", source: .upperMuscle),
        .init(pattern: "ascending part of trapezius", region: "Lower trapezius", function: "Assists lowering and upwardly rotating the shoulder blade.", movement: "Scapular depression and upward rotation", source: .upperMuscle),
        .init(pattern: "brachioradialis", region: "Lateral forearm", function: "Bends the elbow, especially with the thumb facing upward.", movement: "Elbow flexion", source: .upperMuscle),
        .init(pattern: "clavicular head of pectoralis major", region: "Upper chest", function: "Assists bringing the arm forward and across the body.", movement: "Shoulder flexion and adduction", source: .upperMuscle),
        .init(pattern: "sternocostal head of pectoralis major", region: "Chest", function: "Pulls the upper arm toward and across the trunk.", movement: "Shoulder adduction and medial rotation", source: .upperMuscle),
        .init(pattern: "extensor carpi radialis longus", region: "Posterior-lateral forearm", function: "Extends the wrist and moves it toward the thumb side.", movement: "Wrist extension and radial deviation", source: .upperMuscle),
        .init(pattern: "extensor digitorum", region: "Posterior forearm", function: "Straightens fingers two through five and assists wrist extension.", movement: "Finger and wrist extension", source: .upperMuscle),
        .init(pattern: "external abdominal oblique", region: "Lateral abdomen", function: "Compresses the abdomen and assists trunk bending and rotation.", movement: "Trunk flexion, lateral flexion and rotation", source: .headMuscle),
        .init(pattern: "fibularis longus", region: "Lateral lower leg", function: "Turns the sole outward and assists pointing the foot downward.", movement: "Foot eversion and plantar flexion", source: .lowerMuscle),
        .init(pattern: "gluteus maximus", region: "Posterior hip", function: "Extends and turns the thigh outward at the hip.", movement: "Hip extension and lateral rotation", source: .lowerMuscle),
        .init(pattern: "humeral head of flexor carpi ulnaris", region: "Medial forearm", function: "Contributes to bending the wrist and moving it toward the little-finger side.", movement: "Wrist flexion and ulnar deviation", source: .upperMuscle),
        .init(pattern: "ulnar head of flexor carpi ulnaris", region: "Medial forearm", function: "Works with the humeral head to bend and ulnarly deviate the wrist.", movement: "Wrist flexion and ulnar deviation", source: .upperMuscle),
        .init(pattern: "lateral head of gastrocnemius", region: "Outer posterior calf", function: "Assists pointing the foot downward and bending the knee.", movement: "Ankle plantar flexion and knee flexion", source: .lowerMuscle),
        .init(pattern: "medial head of gastrocnemius", region: "Inner posterior calf", function: "Assists pointing the foot downward and bending the knee.", movement: "Ankle plantar flexion and knee flexion", source: .lowerMuscle),
        .init(pattern: "lateral head of triceps brachii", region: "Posterior upper arm", function: "Straightens the elbow.", movement: "Elbow extension", source: .upperMuscle),
        .init(pattern: "long head of triceps brachii", region: "Posterior upper arm", function: "Straightens the elbow and also assists moving the arm backward.", movement: "Elbow extension and shoulder extension", source: .upperMuscle),
        .init(pattern: "latissimus dorsi", region: "Mid and lower back", function: "Pulls the upper arm down, back and inward.", movement: "Shoulder extension, adduction and medial rotation", source: .upperMuscle),
        .init(pattern: "long head of biceps brachii", region: "Anterior upper arm", function: "Assists bending the elbow and turning the palm upward.", movement: "Elbow flexion and forearm supination", source: .upperMuscle),
        .init(pattern: "short head of biceps brachii", region: "Anterior upper arm", function: "Assists bending the elbow and turning the palm upward.", movement: "Elbow flexion and forearm supination", source: .upperMuscle),
        .init(pattern: "long head of biceps femoris", region: "Posterior thigh", function: "Bends the knee and assists extending the hip.", movement: "Knee flexion and hip extension", source: .lowerMuscle),
        .init(pattern: "rectus femoris", region: "Anterior thigh", function: "Straightens the knee and assists raising the thigh forward.", movement: "Knee extension and hip flexion", source: .lowerMuscle),
        .init(pattern: "sartorius", region: "Diagonal anterior thigh", function: "Assists hip flexion, abduction and outward rotation while bending the knee.", movement: "Combined hip motion and knee flexion", source: .lowerMuscle),
        .init(pattern: "semitendinosus", region: "Posterior thigh", function: "Bends the knee and extends the hip.", movement: "Knee flexion and hip extension", source: .lowerMuscle),
        .init(pattern: "tibialis anterior", region: "Front of lower leg", function: "Lifts the foot toward the shin and turns the sole inward.", movement: "Ankle dorsiflexion and foot inversion", source: .lowerMuscle),
        .init(pattern: "vastus lateralis", region: "Outer anterior thigh", function: "Straightens the knee as part of the quadriceps group.", movement: "Knee extension", source: .lowerMuscle),
        .init(pattern: "vastus medialis", region: "Inner anterior thigh", function: "Straightens the knee as part of the quadriceps group.", movement: "Knee extension", source: .lowerMuscle),
        .init(pattern: "clavicle", region: "Front of shoulder girdle", function: "Braces the shoulder away from the trunk and transfers upper-limb force to the axial skeleton.", movement: "Moves with the shoulder girdle", source: .upperBone),
        .init(pattern: "scapula", region: "Posterior shoulder girdle", function: "Provides the socket for the upper arm and broad attachment for shoulder muscles.", movement: "Rotates, elevates, depresses and glides with arm movement", source: .upperBone),
        .init(pattern: "humerus", region: "Upper arm", function: "Connects the shoulder to the elbow and provides leverage for arm muscles.", movement: "Participates in shoulder and elbow motion", source: .upperBone),
        .init(pattern: "radius", region: "Thumb-side forearm", function: "Rotates around the ulna and carries much of the hand's load at the wrist.", movement: "Forearm pronation and supination; wrist motion", source: .upperBone),
        .init(pattern: "ulna", region: "Little-finger-side forearm", function: "Forms the main hinge relationship with the humerus at the elbow.", movement: "Elbow flexion and extension", source: .upperBone),
        .init(pattern: "femur", region: "Thigh", function: "Transfers load between hip and knee and provides leverage for powerful lower-limb muscles.", movement: "Participates in hip and knee motion", source: .lowerBone),
        .init(pattern: "patella", region: "Front of knee", function: "Protects the anterior knee and improves the quadriceps' leverage.", movement: "Glides during knee flexion and extension", source: .lowerBone),
        .init(pattern: "tibia", region: "Medial lower leg", function: "Carries most body weight from the knee to the ankle.", movement: "Participates in knee and ankle motion", source: .lowerBone),
        .init(pattern: "fibula", region: "Lateral lower leg", function: "Stabilizes the ankle region and provides muscle attachment with limited weight bearing.", movement: "Supports ankle mechanics", source: .lowerBone),
        .init(pattern: "hip bone", region: "Pelvic girdle", function: "Forms the hip socket and transfers load between trunk and lower limb.", movement: "Provides the stable base for hip motion", source: .lowerBone),
        .init(pattern: "sacrum", region: "Base of spine", function: "Links the vertebral column with the pelvic girdle.", movement: "Transfers trunk load into the pelvis", source: .axialBone),
        .init(pattern: "calcaneus", region: "Heel", function: "Forms the heel and provides a lever for the calcaneal tendon.", movement: "Supports ankle plantar flexion and weight bearing", source: .lowerBone),
        .init(pattern: "talus", region: "Upper rear foot", function: "Receives lower-leg load and forms key ankle and hindfoot joints.", movement: "Participates in ankle dorsiflexion and plantar flexion", source: .lowerBone),
        .init(pattern: "navicular bone", region: "Medial midfoot", function: "Links the talus with the forefoot and contributes to the medial arch.", movement: "Supports adaptable foot motion", source: .lowerBone),
        .init(pattern: "cuboid bone", region: "Lateral midfoot", function: "Links the heel region with the lateral forefoot and supports the lateral arch.", movement: "Supports adaptable foot motion", source: .lowerBone),
        .init(pattern: "frontal bone", region: "Forehead and anterior skull", function: "Protects the front of the brain and contributes to the eye sockets.", movement: "Structural; joined mainly by immovable sutures", source: .axialBone),
        .init(pattern: "parietal bone", region: "Upper sides of skull", function: "Forms much of the cranial roof and protects the brain.", movement: "Structural; joined by skull sutures", source: .axialBone),
        .init(pattern: "temporal bone", region: "Side and base of skull", function: "Protects structures of the ear and participates in the jaw joint.", movement: "Provides the skull side of jaw articulation", source: .axialBone),
        .init(pattern: "occipital bone", region: "Back and base of skull", function: "Surrounds the spinal opening and articulates with the first cervical vertebra.", movement: "Supports head nodding at the upper neck", source: .axialBone),
        .init(pattern: "mandible", region: "Lower jaw", function: "Holds the lower teeth and is the skull's major freely movable bone.", movement: "Jaw elevation, depression and side-to-side motion", source: .axialBone),
        .init(pattern: "maxilla", region: "Upper jaw and central face", function: "Holds the upper teeth and contributes to the nose, palate and eye sockets.", movement: "Structural support for the face", source: .axialBone),
        .init(pattern: "atlas (c1)", region: "First cervical vertebra", function: "Supports the skull at the top of the spine.", movement: "Primarily supports head nodding", source: .axialBone),
        .init(pattern: "axis (c2)", region: "Second cervical vertebra", function: "Provides the pivot around which the atlas and head rotate.", movement: "Head and upper-neck rotation", source: .axialBone),
        .init(pattern: "body of sternum", region: "Front of chest", function: "Anchors rib cartilages and helps protect thoracic organs.", movement: "Moves subtly with breathing", source: .axialBone),
        .init(pattern: "manubrium", region: "Upper sternum", function: "Connects with the clavicles and upper ribs.", movement: "Supports the shoulder girdle and rib cage", source: .axialBone)
    ]

    static func entry(for selection: AnatomySelection) -> AnatomyKnowledgeEntry? {
        let normalized = selection.name.lowercased()
        return entries.first { normalized.contains($0.pattern) }
    }
}

private enum TwinExplorerMode: String, CaseIterable, Identifiable {
    case body = "Body"
    case anatomy = "Anatomy"
    case joints = "Joints"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .body: TwinBodyLayer.body.symbol
        case .anatomy: TwinBodyLayer.muscles.symbol
        case .joints: TwinBodyLayer.joints.symbol
        }
    }
}

private enum AnatomyRegion: String, CaseIterable, Identifiable {
    case wholeBody = "All regions"
    case headNeck = "Head & neck"
    case shoulderChest = "Shoulder & chest"
    case armForearm = "Arm & forearm"
    case trunk = "Trunk"
    case hipThigh = "Hip & thigh"
    case lowerLegFoot = "Lower leg & foot"

    var id: String { rawValue }

    func contains(_ selection: AnatomySelection) -> Bool {
        guard self != .wholeBody else { return true }
        let name = selection.name.lowercased()
        let terms: [String]
        switch self {
        case .wholeBody:
            return true
        case .headNeck:
            terms = ["frontal", "parietal", "temporal", "occipital", "ethmoid", "maxilla", "mandible", "nasal", "zygomatic", "orbicularis", "frontalis", "occipitalis", "temporalis", "platysma", "cervical", "atlas", "axis", "cricoid", "arytenoid"]
        case .shoulderChest:
            terms = ["deltoid", "trapezius", "pector", "clavicle", "scapula", "sternum", "rib", "thoracic"]
        case .armForearm:
            terms = ["brach", "carpi", "digitorum", "humerus", "radius", "ulna", "antebrachial", "metacarpal", "finger of hand"]
        case .trunk:
            terms = ["abdominal", "latissimus", "lumbar", "sacrum", "coccyx", "vertebra t", "vertebra l"]
        case .hipThigh:
            terms = ["glute", "femur", "patella", "vastus", "rectus femoris", "sartorius", "biceps femoris", "semitendinosus", "hip bone", "fascia lata", "iliotibial", "popliteal"]
        case .lowerLegFoot:
            terms = ["gastrocnemius", "tibialis", "fibularis", "crural", "calcaneal", "plantar", "tibia", "fibula", "calcaneus", "talus", "navicular", "cuboid", "metatarsal", "finger of foot"]
        }
        return terms.contains { name.contains($0) }
    }
}

private enum AnatomyDetailFilter: String, CaseIterable, Identifiable {
    case all = "All tissues"
    case muscle = "Muscle"
    case connective = "Connective"

    var id: String { rawValue }

    func contains(_ selection: AnatomySelection) -> Bool {
        switch self {
        case .all:
            return true
        case .muscle:
            return selection.category == "Muscle"
        case .connective:
            return ["Fascia", "Tendon", "Aponeurosis", "Retinaculum", "Ligament"]
                .contains(selection.category)
        }
    }
}

struct TwinHomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var isShowingProfiles = false
    @State private var isShowingDetails = false
    @State private var isRefiningTwin = false
    @State private var selectedLayer: TwinBodyLayer = .body
    @State private var lastAnatomyLayer: TwinBodyLayer = .muscles
    @State private var sceneResetToken = 0
    @State private var isEditingMobility = false
    @State private var isShowingSettings = false
    @State private var selectedStructure: AnatomySelection?
    @State private var focusedStructure: AnatomySelection?
    @State private var hiddenStructureIDs: Set<String> = []
    @State private var availableStructures: [AnatomySelection] = []
    @State private var isShowingAnatomyBrowser = false
    @State private var anatomyRegion: AnatomyRegion = .wholeBody
    @State private var anatomyDetailFilter: AnatomyDetailFilter = .all

    var body: some View {
        ZStack {
            EidomeTheme.backgroundGradient.ignoresSafeArea()
            ambientGlow

            if let profile = profileStore.selectedProfile {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        topBar(profile)
                        twinStage(profile)
                        identityCard(profile)
                    }
                    .padding(.bottom, 28)
                }
            }
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $isShowingProfiles) {
            ProfileSwitcherSheet()
        }
        .sheet(isPresented: $isShowingDetails) {
            if let profile = profileStore.selectedProfile {
                TwinDetailsView(profile: profile)
            }
        }
        .sheet(isPresented: $isRefiningTwin) {
            if let profile = profileStore.selectedProfile {
                RefineTwinView(profile: profile)
            }
        }
        .sheet(isPresented: $isEditingMobility) {
            if let profile = profileStore.selectedProfile {
                MobilityEditorView(profile: profile)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            AppSettingsView()
        }
        .sheet(isPresented: $isShowingAnatomyBrowser) {
            AnatomyBrowserSheet(
                layer: selectedLayer,
                structures: filteredAvailableStructures,
                selectedStructure: selectedStructure
            ) { selection in
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedStructure = selection
                    focusedStructure = selection
                }
            }
        }
    }

    private var ambientGlow: some View {
        RadialGradient(
            colors: [EidomeTheme.violet.opacity(0.19), .clear],
            center: .top,
            startRadius: 20,
            endRadius: 330
        )
        .ignoresSafeArea()
    }

    private func topBar(_ profile: TwinProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                EidomeWordmark(compact: true)
                    .foregroundStyle(EidomeTheme.cyan)
                Text(profile.name)
                    .font(.title2.bold())
            }
            Spacer()
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(EidomeTheme.panel, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("About, privacy, and support")

            Button {
                isShowingProfiles = true
            } label: {
                HStack(spacing: 8) {
                    Text(profile.name.prefix(1).uppercased())
                        .font(.subheadline.bold())
                        .frame(width: 34, height: 34)
                        .background(EidomeTheme.violet.opacity(0.32), in: Circle())
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(EidomeTheme.panel, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private var selectedMode: TwinExplorerMode {
        switch selectedLayer {
        case .body: .body
        case .muscles, .skeleton: .anatomy
        case .joints: .joints
        }
    }

    private var filteredAvailableStructures: [AnatomySelection] {
        availableStructures.filter { structure in
            anatomyRegion.contains(structure)
                && (selectedLayer != .muscles || anatomyDetailFilter.contains(structure))
        }
    }

    private var sceneHiddenStructureIDs: Set<String> {
        let filteredOut = availableStructures
            .filter { !filteredAvailableStructures.contains($0) }
            .map(\.id)
        return hiddenStructureIDs.union(filteredOut)
    }

    private func twinStage(_ profile: TwinProfile) -> some View {
        VStack(spacing: 12) {
            explorerContextHeader

            modePicker

            if selectedMode == .anatomy {
                anatomyLayerPicker
                    .transition(.opacity.combined(with: .move(edge: .top)))
                anatomyFilters
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            TwinSceneView(
                profile: profile,
                layer: selectedLayer,
                focusedStructure: focusedStructure,
                hiddenStructureIDs: sceneHiddenStructureIDs,
                cameraResetToken: sceneResetToken,
                onAnatomyCatalogChanged: { catalog in
                    availableStructures = catalog
                },
                onStructureSelected: { selection in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if focusedStructure != selection {
                            focusedStructure = nil
                        }
                        selectedStructure = selection
                    }
                }
            )
            .frame(height: 420)
            .id(profile.id)

            HStack(spacing: 10) {
                Text(selectedMode == .anatomy || selectedMode == .joints
                     ? "Tap a structure · Drag to rotate · Pinch to zoom"
                     : "Drag to rotate · Pinch to zoom")
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                Button {
                    sceneResetToken += 1
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.caption.bold())
                        .foregroundStyle(EidomeTheme.cyan)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset 3D view")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(EidomeTheme.panel.opacity(0.84), in: Capsule())
            .padding(.horizontal, 20)

            Label(selectedLayer.modelNote, systemImage: "circle.dashed")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(EidomeTheme.cyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())

            whyThisMattersCard(profile)

            if selectedMode == .body || selectedMode == .anatomy || selectedMode == .joints {
                anatomyBrowseCard
            }

            if !hiddenStructureIDs.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(hiddenStructureIDs.count) structure\(hiddenStructureIDs.count == 1 ? "" : "s") hidden")
                            .font(.caption.bold())
                        Text("Restore the full layer when you finish looking underneath.")
                            .font(.caption2)
                            .foregroundStyle(EidomeTheme.secondaryText)
                    }
                    Spacer()
                    Button("Restore") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            hiddenStructureIDs.removeAll()
                        }
                    }
                    .font(.caption.bold())
                    .foregroundStyle(EidomeTheme.cyan)
                }
                .padding(12)
                .background(EidomeTheme.panel, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
            }

            if let selectedStructure {
                selectionCard(selectedStructure, profile: profile)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                anatomyEmptyState
            }

            contextualAction(profile)
        }
        .padding(.top, 12)
    }

    private var explorerContextHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: selectedMode.symbol)
                .font(.headline)
                .foregroundStyle(EidomeTheme.cyan)
                .frame(width: 38, height: 38)
                .background(EidomeTheme.cyan.opacity(0.11), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(explorerTitle)
                    .font(.headline)
                Text(explorerSubtitle)
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 22)
    }

    private var explorerTitle: String {
        switch selectedMode {
        case .body: "Your body"
        case .anatomy: "Explore what is underneath"
        case .joints: "How you move"
        }
    }

    private var explorerSubtitle: String {
        switch selectedMode {
        case .body:
            "See how your measurements shape this estimate."
        case .anatomy:
            "Inspect reference structures, then connect them to movement."
        case .joints:
            "Review estimated joint locations and add your mobility ranges."
        }
    }

    private var modePicker: some View {
        HStack(spacing: 6) {
            ForEach(TwinExplorerMode.allCases) { mode in
                Button {
                    selectMode(mode)
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: mode.symbol)
                            .font(.body)
                        Text(mode.rawValue)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selectedMode == mode ? Color.white : EidomeTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedMode == mode ? EidomeTheme.violet.opacity(0.32) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedMode == mode ? .isSelected : [])
            }
        }
        .padding(5)
        .background(EidomeTheme.panel, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(EidomeTheme.line, lineWidth: 1)
        }
        .padding(.horizontal, 20)
    }

    private var anatomyLayerPicker: some View {
        HStack(spacing: 6) {
            ForEach([TwinBodyLayer.muscles, .skeleton]) { layer in
                Button {
                    selectLayer(layer)
                } label: {
                    Label(layer.rawValue, systemImage: layer.symbol)
                        .font(.caption.bold())
                        .foregroundStyle(selectedLayer == layer ? Color.white : EidomeTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            selectedLayer == layer ? EidomeTheme.cyan.opacity(0.16) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedLayer == layer ? .isSelected : [])
            }
        }
        .padding(4)
        .background(EidomeTheme.panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 13))
        .padding(.horizontal, 42)
    }

    private var anatomyFilters: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Explore by region")
                    .font(.caption.bold())
                Spacer()
                Text("\(filteredAvailableStructures.count) of \(availableStructures.count) visible")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(EidomeTheme.secondaryText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(AnatomyRegion.allCases) { region in
                        filterChip(region.rawValue, isSelected: anatomyRegion == region) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                anatomyRegion = region
                                clearSelectionIfFilteredOut()
                            }
                        }
                    }
                }
            }

            if selectedLayer == .muscles {
                HStack(spacing: 7) {
                    ForEach(AnatomyDetailFilter.allCases) { detail in
                        filterChip(detail.rawValue, isSelected: anatomyDetailFilter == detail) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                anatomyDetailFilter = detail
                                clearSelectionIfFilteredOut()
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(EidomeTheme.panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }

    private func filterChip(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(isSelected ? Color.white : EidomeTheme.secondaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    isSelected ? EidomeTheme.violet.opacity(0.46) : Color.white.opacity(0.04),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func clearSelectionIfFilteredOut() {
        guard let selectedStructure else { return }
        if !anatomyRegion.contains(selectedStructure)
            || (selectedLayer == .muscles && !anatomyDetailFilter.contains(selectedStructure)) {
            self.selectedStructure = nil
            focusedStructure = nil
        }
    }

    private var anatomyBrowseCard: some View {
        Button {
            isShowingAnatomyBrowser = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.headline)
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(width: 38, height: 38)
                    .background(EidomeTheme.cyan.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedMode == .body ? "Browse measurements" : "Browse structures")
                        .font(.subheadline.bold())
                    Text(
                        availableStructures.isEmpty
                            ? "Loading this reference layer…"
                            : "\(filteredAvailableStructures.count) \(selectedMode == .body ? "body inputs" : selectedMode == .joints ? "named joint landmarks" : "visible reference structures")"
                    )
                    .font(.caption2)
                    .foregroundStyle(EidomeTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(EidomeTheme.secondaryText)
            }
            .padding(12)
            .background(EidomeTheme.panel, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(availableStructures.isEmpty)
        .padding(.horizontal, 20)
        .accessibilityHint("Search and select structures that may be difficult to tap in the 3D model.")
    }

    private var anatomyEmptyState: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap")
                .foregroundStyle(EidomeTheme.cyan)
            Text(
                selectedMode == .body
                    ? "Tap a measurement marker or browse the list to see what shaped this estimate."
                    : selectedMode == .joints
                        ? "Tap a joint marker or browse the list to connect a landmark with movement data."
                        : "Tap the model or browse the structure list to identify and isolate anatomy."
            )
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
            Spacer()
        }
        .padding(12)
        .background(EidomeTheme.panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }

    private func whyThisMattersCard(_ profile: TwinProfile) -> some View {
        let meaning = explorerMeaning(for: profile)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.max")
                    .font(.headline)
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(width: 36, height: 36)
                    .background(EidomeTheme.cyan.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Why this matters")
                        .font(.subheadline.bold())
                    Text(meaning.summary)
                        .font(.caption)
                        .foregroundStyle(EidomeTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            meaningRow(
                symbol: "checkmark.circle",
                title: "Use it for",
                text: meaning.use
            )

            meaningRow(
                symbol: "exclamationmark.shield",
                title: "Keep in mind",
                text: meaning.limit
            )

            Label(meaning.nextStep, systemImage: "arrow.right.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(EidomeTheme.cyan)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Next useful step: \(meaning.nextStep)")
        }
        .padding(14)
        .background(EidomeTheme.panel.opacity(0.82), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(EidomeTheme.cyan.opacity(0.16), lineWidth: 1)
        }
        .padding(.horizontal, 20)
    }

    private func meaningRow(
        symbol: String,
        title: String,
        text: String
    ) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
                .frame(width: 18, alignment: .center)
                .accessibilityHidden(true)

            Text(title + ":")
                .font(.caption.bold())

            Text(text)
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func explorerMeaning(
        for profile: TwinProfile
    ) -> (summary: String, use: String, limit: String, nextStep: String) {
        switch selectedMode {
        case .body:
            let count = profile.bodyMeasurements?.completedCount ?? 0
            let nextMeasurement = nextMissingBodyMeasurement(profile)
            return (
                "Your body view turns the information you enter into a visual estimate you can refine over time.",
                "Understanding which proportions are measured and which are still estimated.",
                "It is not a body scan and does not measure body composition or tissue health.",
                count == 7
                    ? "Your seven regional measurements are entered; update them when your body changes."
                    : "Next useful input: \(nextMeasurement ?? "a regional measurement") (\(7 - count) remaining)."
            )
        case .anatomy:
            if let selectedStructure {
                return (
                    "Anatomy gives the body estimate useful context by naming the structures underneath.",
                    "Learning where \(selectedStructure.name) sits and connecting it to movement.",
                    "Reference anatomy is height-scaled; it does not measure your own muscle size, strength, injury or pain.",
                    "Read the selected structure card, then rotate or isolate it to understand its relationships."
                )
            }
            return (
                "Anatomy gives the body estimate useful context by naming the structures underneath.",
                "Building a spatial map of muscles, fascia and bones before analysing movement.",
                "These are reference structures, not a scan or diagnosis of your body.",
                "Tap a visible structure or use Browse structures to start with a specific question."
            )
        case .joints:
            let count = profile.mobilityProfile?.completedCount ?? 0
            return (
                "Joints connect anatomy to what your body can actually do.",
                "Recording movement ranges so later coaching can use your own mobility context.",
                "The markers are estimated positions and entered ranges are not a clinical assessment.",
                count == 8
                    ? "Your eight mobility fields are entered; repeat them consistently to compare change."
                    : "Measure \(8 - count) more joint range\(8 - count == 1 ? "" : "s") to build your mobility baseline."
            )
        }
    }

    private func nextMissingBodyMeasurement(_ profile: TwinProfile) -> String? {
        let values = profile.bodyMeasurements
        let ordered: [(String, Double?)] = [
            ("waist circumference", values?.waistCircumferenceCentimeters),
            ("hip circumference", values?.hipCircumferenceCentimeters),
            ("chest circumference", values?.chestCircumferenceCentimeters),
            ("shoulder width", values?.shoulderWidthCentimeters),
            ("inseam", values?.inseamCentimeters),
            ("thigh circumference", values?.thighCircumferenceCentimeters),
            ("calf circumference", values?.calfCircumferenceCentimeters)
        ]
        return ordered.first(where: { $0.1 == nil })?.0
    }


    @ViewBuilder
    private func contextualAction(_ profile: TwinProfile) -> some View {
        switch selectedMode {
        case .body:
            improveCard(profile)
        case .anatomy:
            EmptyView()
        case .joints:
            mobilityCard(profile)
        }
    }

    private func selectMode(_ mode: TwinExplorerMode) {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch mode {
            case .body:
                selectedLayer = .body
            case .anatomy:
                selectedLayer = lastAnatomyLayer
            case .joints:
                selectedLayer = .joints
            }
            clearAnatomyInteraction()
        }
    }

    private func selectLayer(_ layer: TwinBodyLayer) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedLayer = layer
            lastAnatomyLayer = layer
            anatomyDetailFilter = .all
            clearAnatomyInteraction()
        }
    }

    private func clearAnatomyInteraction() {
        selectedStructure = nil
        focusedStructure = nil
        hiddenStructureIDs.removeAll()
        availableStructures.removeAll()
        isShowingAnatomyBrowser = false
    }

    @ViewBuilder
    private func selectionCard(
        _ selection: AnatomySelection,
        profile: TwinProfile
    ) -> some View {
        if selection.layer == .body {
            bodyMeasurementCard(selection, profile: profile)
        } else {
            anatomySelectionCard(selection, profile: profile)
        }
    }

    private func bodyMeasurementCard(
        _ selection: AnatomySelection,
        profile: TwinProfile
    ) -> some View {
        let detail = bodyMeasurementDetail(selection, profile: profile)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "ruler")
                    .font(.title3)
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(width: 40, height: 40)
                    .background(EidomeTheme.cyan.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(selection.name).font(.subheadline.bold())
                    Text(detail.source)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(detail.isEntered ? EidomeTheme.cyan : EidomeTheme.secondaryText)
                }
                Spacer()
                Button {
                    selectedStructure = nil
                    focusedStructure = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .frame(width: 30, height: 30)
                        .background(EidomeTheme.panel, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear selected measurement")
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Latest value")
                        .font(.caption2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text(detail.value)
                        .font(.title3.bold().monospacedDigit())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Recorded")
                        .font(.caption2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text(detail.date)
                        .font(.caption.bold())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("How it affects the twin").font(.caption.bold())
                Text(detail.effect)
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
            }

            Button {
                isRefiningTwin = true
            } label: {
                Label(detail.isEntered ? "Update measurement" : "Add measurement", systemImage: "ruler")
                    .font(.caption.bold())
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(EidomeTheme.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .glassCard()
        .padding(.horizontal, 20)
    }

    private func bodyMeasurementDetail(
        _ selection: AnatomySelection,
        profile: TwinProfile
    ) -> (value: String, source: String, date: String, effect: String, isEntered: Bool) {
        let measurements = profile.bodyMeasurements
        let name = selection.name.lowercased()
        let value: Double?
        let effect: String

        if name.contains("shoulder") {
            value = measurements?.shoulderWidthCentimeters
            effect = "Adjusts shoulder breadth relative to the torso."
        } else if name.contains("chest") {
            value = measurements?.chestCircumferenceCentimeters
            effect = "Refines chest width and depth instead of relying only on height and weight."
        } else if name.contains("waist") {
            value = measurements?.waistCircumferenceCentimeters
            effect = "Refines the waist region of the exterior body estimate."
        } else if name.contains("hip") {
            value = measurements?.hipCircumferenceCentimeters
            effect = "Refines hip width and depth in the exterior estimate."
        } else if name.contains("inseam") {
            value = measurements?.inseamCentimeters
            effect = "Adjusts the model's leg-to-torso proportion."
        } else if name.contains("thigh") {
            value = measurements?.thighCircumferenceCentimeters
            effect = "Refines upper-leg volume while preserving overall height."
        } else {
            value = measurements?.calfCircumferenceCentimeters
            effect = "Refines lower-leg volume while preserving overall height."
        }

        let isEntered = value != nil
        return (
            value.map { $0.formatted(.number.precision(.fractionLength(0...1))) + " cm" }
                ?? "Not entered",
            isEntered ? "Entered measurement" : "Estimated from profile inputs",
            isEntered
                ? (profile.measurementsUpdatedAt?.formatted(date: .abbreviated, time: .omitted)
                    ?? "Date not recorded")
                : "Not measured",
            effect,
            isEntered
        )
    }

    private func anatomySelectionCard(
        _ selection: AnatomySelection,
        profile: TwinProfile
    ) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: selection.layer == .muscles
                      ? "figure.strengthtraining.traditional"
                      : selection.layer == .joints ? "circle.grid.cross" : "viewfinder")
                    .font(.title3)
                    .foregroundStyle(selection.layer == .muscles ? Color.red.opacity(0.85) : EidomeTheme.cyan)
                    .frame(width: 40, height: 40)
                    .background(EidomeTheme.panel, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(selection.name)
                        .font(.subheadline.bold())
                        .lineLimit(2)
                    Text([selection.side?.rawValue, selection.category]
                        .compactMap { $0 }
                        .joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text(selection.layer == .joints
                         ? "Estimated landmark · entered ranges shown below"
                         : "Reference anatomy · not measured")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(EidomeTheme.cyan)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedStructure = nil
                        focusedStructure = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .frame(width: 30, height: 30)
                        .background(EidomeTheme.panel, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear selected structure")
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    focusedStructure = focusedStructure == selection ? nil : selection
                }
            } label: {
                Label(
                    focusedStructure == selection ? "Show full layer" : "Isolate structure",
                    systemImage: focusedStructure == selection ? "rectangle.expand.vertical" : "scope"
                )
                .font(.caption.bold())
                .foregroundStyle(EidomeTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(EidomeTheme.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityHint(
                focusedStructure == selection
                    ? "Restores all structures in this anatomy layer."
                    : "Dims surrounding anatomy to make this structure easier to inspect."
            )

            if selection.layer == .joints {
                jointSelectionDetails(selection, profile: profile)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Understand this selection").font(.caption.bold())
                    if let knowledge = AnatomyKnowledge.entry(for: selection) {
                        knowledgeRow("Region", knowledge.region)
                        knowledgeRow("Function", knowledge.function)
                        knowledgeRow("Movement", knowledge.movement)
                        Link(knowledge.source.title, destination: knowledge.source.url)
                            .font(.caption2.weight(.semibold))
                    } else {
                        Text(anatomyExplanation(selection))
                            .font(.caption)
                            .foregroundStyle(EidomeTheme.secondaryText)
                        Link("General anatomy reference: OpenStax A&P 2e",
                             destination: URL(string: "https://openstax.org/books/anatomy-and-physiology-2e/pages/11-introduction")!)
                            .font(.caption2.weight(.semibold))
                    }
                    Text("This reference cannot tell you your muscle strength, tissue health or cause of pain.")
                        .font(.caption2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(selection.layer == .joints
                     ? "Skeleton source: Z-Anatomy / BodyParts3D derivative"
                     : "Source mesh: \(selection.name) · Z-Anatomy derivative")
                    .font(.caption2)
                    .foregroundStyle(EidomeTheme.secondaryText)
                Link(
                    "CC BY-SA 4.0 · attribution and licence",
                    destination: URL(string: "https://github.com/Z-Anatomy/Models-of-human-anatomy/blob/b9c9f98066e1e786814603b047c5bd3638c2a864/License.txt")!
                )
                .font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if selection.category == "Fascia" {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        hiddenStructureIDs.insert(selection.id)
                        selectedStructure = nil
                        focusedStructure = nil
                    }
                } label: {
                    Label("Reveal structures beneath", systemImage: "eye.slash")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(EidomeTheme.violet.opacity(0.34), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityHint("Temporarily hides this fascia so deeper visible structures can be selected.")
            }
        }
        .padding(14)
        .glassCard()
        .padding(.horizontal, 20)
    }

    private func knowledgeRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.bold())
                .tracking(0.6)
                .foregroundStyle(EidomeTheme.cyan)
            Text(value)
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
        }
    }

    @ViewBuilder
    private func jointSelectionDetails(
        _ selection: AnatomySelection,
        profile: TwinProfile
    ) -> some View {
        let detail = jointDetail(selection, mobility: profile.mobilityProfile)

        VStack(alignment: .leading, spacing: 9) {
            Text("Movement context").font(.caption.bold())
            Text(detail.movement)
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
            HStack {
                Text(detail.measurementLabel)
                    .font(.caption)
                Spacer()
                Text(detail.value)
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(detail.isMeasured ? EidomeTheme.cyan : EidomeTheme.secondaryText)
            }
            Text("Entered mobility is self-reported measurement data. It is not a diagnosis or a normal-range assessment.")
                .font(.caption2)
                .foregroundStyle(EidomeTheme.secondaryText)

            Button {
                isEditingMobility = true
            } label: {
                Label("Add or update mobility", systemImage: "ruler")
                    .font(.caption.bold())
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(EidomeTheme.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func jointDetail(
        _ selection: AnatomySelection,
        mobility: MobilityProfile?
    ) -> (movement: String, measurementLabel: String, value: String, isMeasured: Bool) {
        let name = selection.name.lowercased()
        let side = selection.side
        let value: Double?
        let movement: String
        let measurementLabel: String

        if name.contains("ankle") {
            movement = "The ankle supports dorsiflexion and plantar flexion as the foot moves relative to the lower leg."
            measurementLabel = "Entered ankle dorsiflexion"
            value = side == .left
                ? mobility?.leftAnkleDorsiflexion
                : mobility?.rightAnkleDorsiflexion
        } else if name.contains("hip") {
            movement = "The hip supports flexion, extension, rotation and movement toward or away from the midline."
            measurementLabel = "Entered hip internal rotation"
            value = side == .left
                ? mobility?.leftHipInternalRotation
                : mobility?.rightHipInternalRotation
        } else if name.contains("shoulder") {
            movement = "The shoulder complex supports raising, lowering and rotating the arm through several coordinated joints."
            measurementLabel = "Entered shoulder flexion"
            value = side == .left
                ? mobility?.leftShoulderFlexion
                : mobility?.rightShoulderFlexion
        } else if name.contains("elbow") {
            movement = "The elbow primarily bends and straightens the arm; nearby joints also turn the forearm."
            measurementLabel = "Mobility field"
            value = nil
        } else if name.contains("wrist") {
            movement = "The wrist moves the hand forward, backward and side to side."
            measurementLabel = "Mobility field"
            value = nil
        } else {
            movement = "The knee primarily bends and straightens the leg, with limited rotation depending on position."
            measurementLabel = "Mobility field"
            value = nil
        }

        return (
            movement,
            measurementLabel,
            value.map { $0.formatted(.number.precision(.fractionLength(0...1))) + "°" }
                ?? "Not entered",
            value != nil
        )
    }

    private func anatomyExplanation(_ selection: AnatomySelection) -> String {
        let name = selection.name.lowercased()
        if name.contains("gastrocnemius") {
            return "A superficial calf muscle with medial and lateral heads. It points the foot downward and helps bend the knee. It is not the whole calf."
        }
        if name.contains("soleus") {
            return "A calf muscle beneath gastrocnemius. It points the foot downward and contributes to standing and walking."
        }
        if name.contains("tibialis anterior") {
            return "A muscle at the front of the lower leg. It lifts the foot toward the shin and turns the sole inward."
        }
        if name.contains("crural fascia") {
            return "A connective-tissue covering of the lower leg, not one calf muscle. Hide this surface to inspect the underlying structures included in this model."
        }
        return "This source-model label does not yet have a structure-specific explanation. A single selectable surface may cover multiple underlying tissues; this model does not include every depth of anatomy."
    }

    private func identityCard(_ profile: TwinProfile) -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TWIN INPUT COVERAGE")
                        .font(.caption.bold())
                        .tracking(1.2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text("\(profile.completeness)% captured")
                        .font(.title2.bold())
                }
                Spacer()
                completenessRing(profile.completeness)
            }

            ProgressView(value: Double(profile.completeness), total: 100)
                .tint(EidomeTheme.cyan)

            HStack {
                stat("HEIGHT", "\(Int(profile.heightCentimeters)) cm")
                divider
                stat("WEIGHT", "\(Int(profile.weightKilograms)) kg")
                divider
                stat("AGE", "\(profile.age)")
            }

            Text("Coverage reflects information you entered, not anatomical or medical confidence.")
                .font(.caption2)
                .foregroundStyle(EidomeTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("View model details") { isShowingDetails = true }
                .font(.subheadline.bold())
                .foregroundStyle(EidomeTheme.cyan)
        }
        .padding(20)
        .glassCard()
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private func improveCard(_ profile: TwinProfile) -> some View {
        Button {
            isRefiningTwin = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "ruler")
                    .font(.title2)
                    .foregroundStyle(EidomeTheme.violet)
                    .frame(width: 44, height: 44)
                    .background(EidomeTheme.violet.opacity(0.14), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.bodyMeasurements?.isEmpty == false ? "Refine body shape" : "Shape this twin")
                        .font(.headline)
                    Text("\(profile.bodyMeasurements?.completedCount ?? 0) of 7 body measurements added")
                        .font(.caption)
                        .foregroundStyle(EidomeTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(EidomeTheme.secondaryText)
            }
            .padding(18)
            .glassCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Shape this twin with body measurements.")
    }

    private func mobilityCard(_ profile: TwinProfile) -> some View {
        Button {
            isEditingMobility = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "figure.flexibility")
                    .font(.title2)
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(width: 44, height: 44)
                    .background(EidomeTheme.cyan.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Map mobility")
                        .font(.headline)
                    Text("\(profile.mobilityProfile?.completedCount ?? 0) of 8 joint ranges measured")
                        .font(.caption)
                        .foregroundStyle(EidomeTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(EidomeTheme.secondaryText)
            }
            .padding(18)
            .glassCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private func completenessRing(_ value: Int) -> some View {
        ZStack {
            Circle().stroke(EidomeTheme.line, lineWidth: 6)
            Circle()
                .trim(from: 0, to: Double(value) / 100)
                .stroke(EidomeTheme.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(value)%")
                .font(.caption.bold().monospacedDigit())
        }
        .frame(width: 58, height: 58)
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption2.bold())
                .tracking(0.8)
                .foregroundStyle(EidomeTheme.secondaryText)
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle().fill(EidomeTheme.line).frame(width: 1, height: 34)
    }
}


private struct AnatomyBrowserSheet: View {
    @Environment(\.dismiss) private var dismiss
    let layer: TwinBodyLayer
    let structures: [AnatomySelection]
    let selectedStructure: AnatomySelection?
    let onSelect: (AnatomySelection) -> Void

    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private var categories: [String] {
        ["All"] + Set(structures.map(\.category)).sorted()
    }

    private var filteredStructures: [AnatomySelection] {
        structures.filter { structure in
            let matchesCategory =
                selectedCategory == "All" || structure.category == selectedCategory
            let haystack = [
                structure.name,
                structure.category,
                structure.side?.rawValue ?? ""
            ].joined(separator: " ")
            let matchesSearch =
                searchText.isEmpty ||
                haystack.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    private var groupedStructures: [(category: String, values: [AnatomySelection])] {
        Dictionary(grouping: filteredStructures, by: \.category)
            .map { entry in
                let (category, values) = entry
                return (
                    category,
                    values.sorted {
                        if $0.name != $1.name {
                            return $0.name.localizedCaseInsensitiveCompare($1.name)
                                == .orderedAscending
                        }
                        return ($0.side?.rawValue ?? "") < ($1.side?.rawValue ?? "")
                    }
                )
            }
            .sorted {
                $0.category.localizedCaseInsensitiveCompare($1.category) == .orderedAscending
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(category) {
                                selectedCategory = category
                            }
                            .font(.caption.bold())
                            .foregroundStyle(
                                selectedCategory == category
                                    ? Color.white
                                    : EidomeTheme.secondaryText
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                    ? EidomeTheme.violet.opacity(0.52)
                                    : EidomeTheme.panel,
                                in: Capsule()
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                if groupedStructures.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(groupedStructures, id: \.category) { group in
                            Section(group.category) {
                                ForEach(group.values) { structure in
                                    Button {
                                        onSelect(structure)
                                        dismiss()
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: structure == selectedStructure
                                                  ? "checkmark.circle.fill"
                                                  : "circle")
                                                .foregroundStyle(EidomeTheme.cyan)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(structure.name)
                                                    .foregroundStyle(.primary)
                                                Text(
                                                    [structure.side?.rawValue, structure.category]
                                                        .compactMap { $0 }
                                                        .joined(separator: " · ")
                                                )
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Section {
                            Text(layer == .body
                                 ? "Body markers identify model inputs. Missing values remain estimates derived from the profile's height, weight and other entered measurements."
                                 : layer == .joints
                                    ? "Joint markers are estimated landmarks aligned to the reference skeleton; they are not measured joint centres."
                                    : "Names and selection granularity follow the source anatomy mesh. Some surfaces, including fascia, cover several underlying muscles.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(layer == .body
                ? "Body measurements"
                : layer == .muscles
                    ? "Muscle structures"
                    : layer == .joints ? "Joint landmarks" : "Skeletal structures")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                prompt: layer == .body ? "Search measurements" : "Search structures"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct TwinDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let profile: TwinProfile

    var body: some View {
        NavigationStack {
            ZStack {
                EidomeTheme.backgroundGradient.ignoresSafeArea()
                List {
                    Section("Identity") {
                        detail("Name", profile.name)
                        detail("Relationship", profile.relationship.rawValue)
                        detail("Age", "\(profile.age) years")
                        detail("Biological sex", profile.biologicalSex.rawValue)
                    }
                    Section("Measured") {
                        detail("Height", "\(Int(profile.heightCentimeters)) cm")
                        detail("Weight", "\(Int(profile.weightKilograms)) kg")
                        if let measurements = profile.bodyMeasurements {
                            measurementDetails(measurements)
                        }
                    }
                    Section("Derived") {
                        detail("BMI", String(format: "%.1f", profile.bmi))
                    }
                    Section("Model confidence") {
                        Label("The avatar is estimated from your inputs; it does not measure body composition or internal anatomy. Added measurements refine proportions, not medical accuracy.", systemImage: "info.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Twin details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func detail(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func measurementDetails(_ values: BodyMeasurements) -> some View {
        optionalDetail("Shoulders", values.shoulderWidthCentimeters)
        optionalDetail("Chest", values.chestCircumferenceCentimeters)
        optionalDetail("Waist", values.waistCircumferenceCentimeters)
        optionalDetail("Hips", values.hipCircumferenceCentimeters)
        optionalDetail("Inseam", values.inseamCentimeters)
        optionalDetail("Thigh", values.thighCircumferenceCentimeters)
        optionalDetail("Calf", values.calfCircumferenceCentimeters)
    }

    @ViewBuilder
    private func optionalDetail(_ label: String, _ value: Double?) -> some View {
        if let value {
            detail(label, value.formatted(.number.precision(.fractionLength(0...1))) + " cm")
        }
    }
}

private struct RefineTwinView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore
    let profile: TwinProfile
    @State private var measurements: BodyMeasurements
    @State private var heightCentimeters: Double
    @State private var weightKilograms: Double

    init(profile: TwinProfile) {
        self.profile = profile
        _measurements = State(initialValue: profile.bodyMeasurements ?? BodyMeasurements())
        _heightCentimeters = State(initialValue: profile.heightCentimeters)
        _weightKilograms = State(initialValue: profile.weightKilograms)
    }

    private var previewProfile: TwinProfile {
        var copy = profile
        copy.heightCentimeters = heightCentimeters
        copy.weightKilograms = weightKilograms
        copy.bodyMeasurements = measurements.isEmpty ? nil : measurements
        return copy
    }

    private var invalidFieldCount: Int {
        let optionalMeasurementErrors = [
            (measurements.shoulderWidthCentimeters, 20.0...70.0),
            (measurements.chestCircumferenceCentimeters, 40.0...180.0),
            (measurements.waistCircumferenceCentimeters, 35.0...180.0),
            (measurements.hipCircumferenceCentimeters, 40.0...180.0),
            (measurements.inseamCentimeters, 35.0...130.0),
            (measurements.thighCircumferenceCentimeters, 20.0...100.0),
            (measurements.calfCircumferenceCentimeters, 15.0...70.0)
        ].filter { entry in
            guard let value = entry.0 else { return false }
            return !entry.1.contains(value)
        }.count

        let requiredMetricErrors = [
            (80.0...230.0).contains(heightCentimeters),
            (15.0...250.0).contains(weightKilograms)
        ].filter { !$0 }.count

        return optionalMeasurementErrors + requiredMetricErrors
    }

    var body: some View {
        NavigationStack {
            ZStack {
                EidomeTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        TwinSceneView(profile: previewProfile)
                            .frame(height: 300)
                            .accessibilityLabel("Live preview of \(profile.name)'s body model")

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Shape \(profile.name)'s twin")
                                .font(.title2.bold())
                            Text("Add only what you have measured. Each value updates the model above and can be changed later.")
                                .font(.subheadline)
                                .foregroundStyle(EidomeTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 0) {
                            RequiredMetricInputRow(
                                title: "Height",
                                value: $heightCentimeters,
                                unit: "cm"
                            )
                            Rectangle()
                                .fill(EidomeTheme.line)
                                .frame(height: 1)
                                .padding(.leading, 16)
                            RequiredMetricInputRow(
                                title: "Weight",
                                value: $weightKilograms,
                                unit: "kg"
                            )
                        }
                        .glassCard()

                        Text("Height sets overall scale. Weight drives an estimated shape; circumferences replace regional estimates with measured inputs.")
                            .font(.caption)
                            .foregroundStyle(EidomeTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 0) {
                            MeasurementInputRow(title: "Shoulder width", value: $measurements.shoulderWidthCentimeters)
                            MeasurementInputRow(title: "Chest circumference", value: $measurements.chestCircumferenceCentimeters)
                            MeasurementInputRow(title: "Waist circumference", value: $measurements.waistCircumferenceCentimeters)
                            MeasurementInputRow(title: "Hip circumference", value: $measurements.hipCircumferenceCentimeters)
                            MeasurementInputRow(title: "Inseam", value: $measurements.inseamCentimeters)
                            MeasurementInputRow(title: "Thigh circumference", value: $measurements.thighCircumferenceCentimeters)
                            MeasurementInputRow(title: "Calf circumference", value: $measurements.calfCircumferenceCentimeters, showsDivider: false)
                        }
                        .glassCard()

                        HStack(spacing: 12) {
                            provenanceLabel("Measured", color: EidomeTheme.cyan)
                            provenanceLabel("Derived", color: EidomeTheme.violet)
                            provenanceLabel("Estimated", color: EidomeTheme.secondaryText)
                        }

                        if invalidFieldCount > 0 {
                            Label("Check \(invalidFieldCount) measurement\(invalidFieldCount == 1 ? "" : "s").", systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                }
            }
            .foregroundStyle(.white)
            .navigationTitle("Body measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = profile
                        updated.heightCentimeters = heightCentimeters
                        updated.weightKilograms = weightKilograms
                        updated.bodyMeasurements = measurements.isEmpty ? nil : measurements
                        updated.measurementsUpdatedAt = measurements.isEmpty ? nil : .now
                        profileStore.update(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(invalidFieldCount > 0)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func provenanceLabel(_ title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(title).font(.caption2.weight(.semibold))
        }
        .foregroundStyle(EidomeTheme.secondaryText)
    }
}

private struct MeasurementInputRow: View {
    let title: String
    @Binding var value: Double?
    var showsDivider = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.subheadline)
                Spacer()
                TextField("—", value: $value, format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.body.monospacedDigit())
                    .frame(width: 76)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                Text("cm")
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .frame(width: 22, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)

            if showsDivider {
                Rectangle()
                    .fill(EidomeTheme.line)
                    .frame(height: 1)
                    .padding(.leading, 16)
            }
        }
    }
}


private struct RequiredMetricInputRow: View {
    let title: String
    @Binding var value: Double
    let unit: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
            Spacer()
            TextField(
                "—",
                value: $value,
                format: .number.precision(.fractionLength(0...1))
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(.body.monospacedDigit())
            .frame(width: 76)
            .padding(.vertical, 9)
            .padding(.horizontal, 10)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            Text(unit)
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
                .frame(width: 22, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}
