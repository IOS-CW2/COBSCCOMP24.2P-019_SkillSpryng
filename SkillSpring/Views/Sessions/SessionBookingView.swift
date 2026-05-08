import SwiftUI

// MARK: - SessionBookingView
// Booking flow screen where the learner chooses format, date, time,
// venue (if in-person), and confirms payment or request submission.
struct SessionBookingView: View {
    let instructor: MatchProfile
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var busyTimeSlots: [DateInterval] = []
    @State private var showCalendarToast = false
    @State private var navigateToWallet = false
    @State private var showMeetingSpot = false
    @State private var selectedVenueName: String? = nil
    
    init(instructor: MatchProfile) {
        self.instructor = instructor
        _viewModel = StateObject(wrappedValue: BookingViewModel(instructor: instructor))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                AppHeader(title: "Session Booking", backAction: { dismiss() })
                
                // Instructor Brief
                HStack(spacing: 16) {
                    Image(instructor.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Book a Session")
                            .font(AppTheme.Typography.title3)
                        Text("with \(instructor.fullName) • \(instructor.role)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", instructor.rating))
                            .font(AppTheme.Typography.badge)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Book a Session with \(instructor.fullName), \(instructor.role), \(String(format: "%.1f", instructor.rating)) stars")
                
                // Format Selector
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "SESSION FORMAT")
                    FormatSelector(isOnline: $viewModel.isOnline)
                }
                .padding(.horizontal)

                // Meeting Spot — only shown for in-person sessions
                if !viewModel.isOnline {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "MEETING VENUE")

                        Button(action: { showMeetingSpot = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(AppTheme.Colors.primary)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: 2) {
                                    if let venue = selectedVenueName {
                                        Text(venue)
                                            .font(AppTheme.Typography.subheadline)
                                            .foregroundColor(.primary)
                                        Text("Tap to change venue")
                                            .font(AppTheme.Typography.caption2)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Choose a Meeting Spot")
                                            .font(AppTheme.Typography.subheadline)
                                            .foregroundColor(AppTheme.Colors.primary)
                                        Text("Public venues near you — libraries, cafés, community centres")
                                            .font(AppTheme.Typography.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedVenueName != nil ? AppTheme.Colors.primary.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                        .accessibilityLabel(selectedVenueName != nil ? "Selected venue: \(selectedVenueName!). Tap to change." : "Choose a meeting spot")
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showMeetingSpot) {
                        MeetingSpotView { spot in
                            selectedVenueName = spot.name
                            viewModel.selectedVenueName = spot.name
                            showMeetingSpot = false
                        }
                    }
                }
                
                // Date Selector
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        SectionHeader(title: "SELECT DATE")
                        Spacer()
                        Text(viewModel.dateStripHeader)
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.primary)
                            .animation(.easeInOut, value: viewModel.selectedDate)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.availableDates, id: \.self) { date in
                                let dayNum = Calendar.current.component(.day, from: date)
                                let weekday = date.formatted(.dateTime.weekday(.abbreviated))
                                DateChip(
                                    date: dayNum,
                                    day: weekday,
                                    isSelected: Calendar.current.isDate(viewModel.selectedDate, inSameDayAs: date)
                                ) {
                                    viewModel.selectedDate = date
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .onChange(of: viewModel.selectedDate) { _ in
                    checkAvailability()
                }
                .onAppear {
                    checkAvailability()
                }
                
                // Time Selector
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "AVAILABLE TIMES")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["09:00 AM", "10:30 AM", "12:00 PM", "01:30 PM", "03:00 PM"], id: \.self) { time in
                                let isAvailable = checkSlotAvailable(timeString: time)
                                
                                Button(action: {
                                    if isAvailable { viewModel.selectedTime = time }
                                }) {
                                    Text(time)
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundColor(viewModel.selectedTime == time ? .white : (isAvailable ? AppTheme.Colors.primary : .secondary))
                                        .strikethrough(!isAvailable)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            viewModel.selectedTime == time ? AppTheme.Colors.primary : Color.clear
                                        )
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(viewModel.selectedTime == time ? AppTheme.Colors.primary : (isAvailable ? AppTheme.Colors.primary.opacity(0.3) : Color.gray.opacity(0.3)), lineWidth: 1)
                                        )
                                }
                                .disabled(!isAvailable)
                                .opacity(isAvailable ? 1.0 : 0.4)
                                .accessibilityLabel("\(time), \(isAvailable ? "available" : "unavailable")")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Duration Selector
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "DURATION")
                    
                    HStack(spacing: 12) {
                        ForEach([30, 60, 90], id: \.self) { duration in
                            SelectionChip(title: "\(duration) min", isSelected: viewModel.selectedDuration == duration) {
                                viewModel.selectedDuration = duration
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Topics and Goals
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "TOPICS AND GOALS")
                    
                    TextEditor(text: $viewModel.topicsAndGoals)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .overlay(
                            VStack {
                                if viewModel.topicsAndGoals.isEmpty {
                                    Text("What would you like to learn and share specific challenges or project details...")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(.gray)
                                        .padding(.top, 24)
                                        .padding(.horizontal, 16)
                                }
                                Spacer()
                            },
                            alignment: .topLeading
                        )
                        .accessibilityLabel("Topics and Goals")
                        .accessibilityHint("What would you like to learn and share specific challenges or project details...")
                }
                .padding(.horizontal)
                
                // Price Preview (if active/paid)
                if instructor.status == .active {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Session (\(viewModel.selectedDuration) min)")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(viewModel.sessionPrice) SKP")
                                .font(AppTheme.Typography.subheadline)
                        }
                        HStack {
                            Text("Platform Fee")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(viewModel.platformFee) SKP")
                                .font(AppTheme.Typography.subheadline)
                        }
                        Divider()
                        HStack {
                            Text("Total Cost")
                                .font(AppTheme.Typography.headline)
                            Spacer()
                            Text("\(viewModel.totalPrice) SKP")
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Action Button
                Button(action: { viewModel.initiateBooking() }) {
                    Text(instructor.status == .active ? "Confirm & Pay \(viewModel.totalPrice) SKP ->" : "Send Request ->")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                .accessibilityButton(
                    label: instructor.status == .active
                        ? "Confirm and Pay \(viewModel.totalPrice) SKP"
                        : "Send Booking Request",
                    hint: instructor.status == .active
                        ? "Deducts \(viewModel.totalPrice) SKP from your wallet and confirms the session"
                        : "Sends a skill-swap request to \(instructor.fullName)"
                )
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .sheet(isPresented: $viewModel.showPaymentSheet) {
            PaySessionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showInsufficientFunds) {
            InsufficientFundsSheet(onTopUp: { navigateToWallet = true })
        }
        .navigationDestination(isPresented: $navigateToWallet) {
            WalletView()
        }
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            SessionSuccessView(viewModel: viewModel)
        }
        // Show the request confirmation screen after successful booking.
        .fullScreenCover(isPresented: $viewModel.showRequestSent) {
            BookingRequestSentView(
                instructor: instructor,
                sessionDate: viewModel.selectedDate,
                time: viewModel.selectedTime,
                isOnline: viewModel.isOnline,
                duration: viewModel.selectedDuration
            )
        }
    }
    
    // MARK: - Availability Checking
    
    private func checkAvailability() {
        Task {
            if CalendarService.shared.checkCalendarAccess() {
                // Use the real selected date directly
                let slots = CalendarService.shared.getBusyTimeSlots(on: viewModel.selectedDate)
                await MainActor.run {
                    self.busyTimeSlots = slots
                }
            } else {
                // Request access on first attempt
                _ = await CalendarService.shared.requestAccess()
                let slots = CalendarService.shared.getBusyTimeSlots(on: viewModel.selectedDate)
                await MainActor.run {
                    self.busyTimeSlots = slots
                }
            }
        }
    }
    
    private func checkSlotAvailable(timeString: String) -> Bool {
        let startTime = viewModel.buildSessionDate(day: viewModel.selectedDate, timeString: timeString)
        return CalendarService.shared.isTimeSlotAvailable(
            startTime: startTime,
            durationMinutes: viewModel.selectedDuration,
            busySlots: busyTimeSlots
        )
    }
}
