import SwiftUI

struct SessionBookingView: View {
    let instructor: MatchProfile
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var busyTimeSlots: [DateInterval] = []
    @State private var showCalendarToast = false
    
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Book a Session")
                            .font(.system(size: 20, weight: .bold))
                        Text("with \(instructor.fullName) • \(instructor.role)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", instructor.rating))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Format Selector
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "SESSION FORMAT")
                    FormatSelector(isOnline: $viewModel.isOnline)
                }
                .padding(.horizontal)
                
                // Date Selector
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        SectionHeader(title: "SELECT DATE")
                        Spacer()
                        Text(viewModel.dateStripHeader)
                            .font(.system(size: 12, weight: .bold))
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
                                        .font(.system(size: 14, weight: .bold))
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
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.top, 24)
                                        .padding(.horizontal, 16)
                                }
                                Spacer()
                            },
                            alignment: .topLeading
                        )
                }
                .padding(.horizontal)
                
                // Price Preview (if active/paid)
                if instructor.status == .active {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Session (\(viewModel.selectedDuration) min)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(viewModel.sessionPrice) SKP")
                                .font(.system(size: 14, weight: .bold))
                        }
                        HStack {
                            Text("Platform Fee")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(viewModel.platformFee) SKP")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Divider()
                        HStack {
                            Text("Total Cost")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Text("\(viewModel.totalPrice) SKP")
                                .font(.system(size: 20, weight: .bold))
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .sheet(isPresented: $viewModel.showPaymentSheet) {
            PaySessionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showInsufficientFunds) {
            InsufficientFundsSheet()
        }
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            SessionSuccessView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.showRequestSent) {
            BookingRequestSentView(instructor: instructor, sessionDate: viewModel.selectedDate, time: viewModel.selectedTime)
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
