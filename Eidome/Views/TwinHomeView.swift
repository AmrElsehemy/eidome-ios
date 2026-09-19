import SwiftUI

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
                structures: availableStructures,
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

    private func twinStage(_ profile: TwinProfile) -> some View {
        VStack(spacing: 12) {
            explorerContextHeader

            modePicker

            if selectedMode == .anatomy {
                anatomyLayerPicker
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            TwinSceneView(
                profile: profile,
                layer: selectedLayer,
                focusedStructure: focusedStructure,
                hiddenStructureIDs: hiddenStructureIDs,
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
                Text(selectedMode == .anatomy
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

            if selectedMode == .anatomy {
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
                anatomySelectionCard(selectedStructure)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if selectedMode == .anatomy {
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
                    Text("Browse structures")
                        .font(.subheadline.bold())
                    Text(
                        availableStructures.isEmpty
                            ? "Loading this anatomy layer…"
                            : "\(availableStructures.count) named reference structures"
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
            Text("Tap the model or browse the structure list to identify and isolate anatomy.")
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
            Spacer()
        }
        .padding(12)
        .background(EidomeTheme.panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
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
            clearAnatomyInteraction()
        }
    }

    private func clearAnatomyInteraction() {
        selectedStructure = nil
        focusedStructure = nil
        hiddenStructureIDs.removeAll()
    }

    private func anatomySelectionCard(_ selection: AnatomySelection) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: selection.layer == .muscles ? "figure.strengthtraining.traditional" : "viewfinder")
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
                    Text("Reference anatomy · not measured")
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

            VStack(alignment: .leading, spacing: 8) {
                Text("Understand this selection").font(.caption.bold())
                Text(anatomyExplanation(selection))
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                Text("This reference cannot tell you your muscle strength, tissue health or cause of pain.")
                    .font(.caption2)
                    .foregroundStyle(EidomeTheme.secondaryText)
                Link("Anatomy reference: OpenStax §11.6",
                     destination: URL(string: "https://openstax.org/books/anatomy-and-physiology-2e/pages/11-6-appendicular-muscles-of-the-pelvic-girdle-and-lower-limbs")!)
                    .font(.caption2)
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
        return "The label identifies a source-model structure. A structure-specific explanation is not yet available here. A single selectable surface may cover multiple underlying tissues; this model does not include every depth of anatomy."
    }

    private func identityCard(_ profile: TwinProfile) -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DIGITAL TWIN")
                        .font(.caption.bold())
                        .tracking(1.2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text("\(profile.completeness)% complete")
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
            .map { category, values in
                (
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
                            Text(
                                "Names and selection granularity follow the source anatomy mesh. "
                                + "Some surfaces, including fascia, cover several underlying muscles."
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(layer == .muscles ? "Muscle structures" : "Skeletal structures")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search structures")
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
