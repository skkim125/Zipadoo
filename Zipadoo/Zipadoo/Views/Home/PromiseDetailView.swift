//
//  PromiseDetailView.swift
//  Zipadoo
//
//  Created by 아라 on 2023/09/21.
//

import SwiftUI
import UIKit
import MapKit

// MARK: - 약속 디테일뷰
struct PromiseDetailView: View {
    @ObservedObject private var promiseDetailStore = PromiseDetailStore()
    @ObservedObject var locationStore: LocationStore = LocationStore()
    @StateObject var loginUser: UserStore = UserStore()
    @EnvironmentObject var promiseViewModel: PromiseViewModel
    @EnvironmentObject var widgetStore: WidgetStore
    
    @Environment(\.dismiss) private var dismiss
    /// 현재 시간
    @State private var currentDate: Double = 0.0
    /// 남은 시간
    @State private var remainingTime: Double = 0.0
    /// 약속수정뷰 시트 Bool값
    @State private var isShowingEditSheet: Bool = false
    /// 약속공유 시트 Bool값
    @State private var isShowingShareSheet: Bool = false
    /// 약속삭제 시트 Bool값
    @State private var isShowingDeleteAlert: Bool = false
    /// 뒤로가기 Bool값
    @State private var isNavigateBackToHome: Bool = false
    
    @State var promise: Promise // 약속 데이터 받는 변수
    
    let activeColor: UIColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    let disabledColor: UIColor = #colorLiteral(red: 0.7725487947, green: 0.772549212, blue: 0.7811570764, alpha: 1)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 약속시간 30분 전 활성화 시킬 때 상태바
    var destinagionStatus: SharingStatus {
        remainingTime > 60 * 30 ? .preparing : .sharing
    }
    var statusColor: Color {
        destinagionStatus == .preparing ? Color(disabledColor) : Color(activeColor)
    }
    
    @State private var region: MapCameraPosition = .automatic
    // MARK: - PromiseDetailView body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    destinationMapView
                        .frame(width: 400, height: 200 , alignment: .center)
                    VStack(alignment: .leading) {
                        titleView
                        
                        destinationView
                        
                        dateView
                        
                        remainingTimeView
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom, 5)
                    //                .overlay(
                    //                    RoundedRectangle(cornerRadius: 10)
                    //                        .foregroundColor(.primary)
                    //                        .opacity(0.05)
                    //                        .shadow(color: .primary, radius: 10, x: 5, y: 5)
                    //                )
                    VStack {
                        participantsView
                    }
                    .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
//            .padding(15)
            // MARK: - 더보기 버튼(삭제, 수정, 약속나가기)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    moreButtonView
                }
            }
        }
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("약속 내역을 삭제합니다."),
                message: Text("해당 작업은 복구되지 않습니다."),
                primaryButton: .destructive(Text("삭제하기"), action: {
                    Task {
                        do {
                            try await promiseViewModel.deletePromiseData(promiseId: promise.id, locationIdArray: promise.locationIdArray)
                            dismiss()
                        } catch {
                            print("실패")
                        }
                    }
                }),
                secondaryButton: .default(Text("돌아가기"), action: {
                })
            )
        }
        .onAppear {
            currentDate = Date().timeIntervalSince1970
            formatRemainingTime()
            widgetStore.widgetPromiseID = nil
            widgetStore.widgetPromise = nil
            widgetStore.isShowingDetailForWidget = false
        }
        .onReceive(timer, perform: { _ in
            currentDate = Date().timeIntervalSince1970
        })
        .onAppear {
            if isNavigateBackToHome {
                dismiss()
            }
            Task {
                try await promiseViewModel.fetchData(userId: AuthStore.shared.currentUser?.id ?? "")
            }
        }
        .refreshable {
            Task {
                try await promiseViewModel.fetchData(userId: AuthStore.shared.currentUser?.id ?? "")
            }
        }
        .sheet(isPresented: $isShowingEditSheet,
               content: { PromiseEditView(promise: .constant(promise), navigationBackToHome: $isNavigateBackToHome)
        })
        .sheet(
            isPresented: $isShowingShareSheet,
            onDismiss: { print("Dismiss") },
            content: { ActivityViewController(activityItems: ["https://zipadoo.onelink.me/QgIh/51ibebbu"]) }
        )
    }
    
    // MARK: - some Views
    private var moreButtonView: some View {
        HStack {
            Button {
                isShowingShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            
            Menu {
                if loginUser.currentUser?.id == promise.makingUserID {
                    NavigationLink {
                        PromiseEditView(promise: .constant(promise), navigationBackToHome: $isNavigateBackToHome)
                    } label: {
                        Text("수정")
                    }
                } else if promise.participantIdArray.contains(loginUser.currentUser?.id ?? "") {
                    Button {
                        if let userId = loginUser.currentUser?.id {
                            // 현재 로그인한 사용자 아이디 가져오기
                            
                            if let index = promise.participantIdArray.firstIndex(of: userId) {
                                // 배열에서 ID 위치 확인
                                // 해당 ID 배열에서 제거
                                let locationIndex = index + 1
                                promise.participantIdArray.remove(at: index)
                                promise.locationIdArray.remove(at: locationIndex) // 약속 나가기 오류발견!
                            }
                            
                            Task {
                                try await promiseViewModel.exitPromise(promise, locationId: userId)
                            }
                        }
                    } label: {
                        Text("약속나가기")
                    }
                }
                
                if loginUser.currentUser?.id == promise.makingUserID {
                    Button {
                        isShowingDeleteAlert.toggle()
                    } label: {
                        Text("삭제")
                    }
                }
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .foregroundColor(.secondary)
    }
    
    private var participantsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("모이는 두더지 친구들")
                    .font(.title3).bold()
                
                Spacer()
            }
            HStack {
                Image(systemName: "info.circle")
                Text("약속시간 30분 전부터 위치가 공유됩니다.")
            }
            .foregroundColor(.secondary)
            .font(.caption)
            .padding(.bottom)
            
//            ForEach(locationStore.locationParticipantDatas) { friends in
//                VStack(alignment: .leading) {
//                    Image(friends.moleImageString)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 50, height: 50)
//                        .padding(.bottom, 5)
//                    
//                    Text(friends.nickname)
//                }
//            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .foregroundColor(.primary)
//                    .opacity(0.05)
//                    .shadow(color: .primary, radius: 10, x: 5, y: 5)
//            )
            // MARK: - 약속 친구 리스트 테스트
            VStack {
                Image(loginUser.currentUser?.moleImageString ?? "- No image -")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding(.bottom, 5)
                
                Text(loginUser.currentUser?.nickName ?? "- No NickName -")
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.primary)
                    .opacity(0.05)
                    .shadow(color: .primary, radius: 10, x: 5, y: 5)
            )
        }
        .padding(.top)
        .padding(.bottom)
    }
    // MARK: - 시간 변환 함수
    private func calculateDate(date: Double) -> String {
        let date = Date(timeIntervalSince1970: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 | a hh:mm"
        return dateFormatter.string(from: date)
    }
    // MARK: - 약속 시간까지의 남은 time 단위 변환 함수
    private func formatRemainingTime() -> String {
        let promiseDate = promise.promiseDate
        remainingTime = promiseDate - currentDate
        switch remainingTime {
        case 1..<60: // 초
            let second = Int(remainingTime) % 60
            return String(format: "약속까지 %02d초 전", second)
        case 60..<1800: // 분 + 초
            let minute = Int(remainingTime) / 60
            let second = Int(remainingTime) % 60
            return String(format: "약속까지 %02d분 %02d초 전", minute, second)
        case 1800..<3600: // 분
            let minute = Int(remainingTime) / 60
            return "약속까지 \(minute)분 전"
        case 3600..<86400: // 시간 + 분
            let hours = remainingTime / (60 * 60)
            let minute = Int(remainingTime) % (60 * 60) / 60
            var message = "약속까지 \(Int(hours))시간 "
            message += minute == 0 ? "전" : " \(minute)분 전"
            return message
        case 86400...: // 일
            let days = calculateRemainingDate(current: currentDate, promise: promiseDate)
            return "약속까지 \(days)일 전"
        default: // 약속 시간일 때
            return "약속 시간이 됐어요!"
        }
    }
    // MARK: - 약속 시간까지의 남은 day 단위 변환 함수
    private func calculateRemainingDate(current: Double, promise: Double) -> Int {
        let calendar = Calendar.current
        
        let nowDate = Date(timeIntervalSince1970: current)
        let promiseDate = Date(timeIntervalSince1970: promise)
        
        let startOfToday = calendar.startOfDay(for: nowDate)
        let startOfPromiseDay = calendar.startOfDay(for: promiseDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfPromiseDay)
        
        if let days = components.day {
            return days
        }
        
        return -1
    }
}
// MARK: - PromiseDetailView extension (ArriveResult뷰에서 재사용 위해 extension으로 분리)
extension PromiseDetailView {
    var destinationMapView: some View {
        Map(position: $region, bounds: MapCameraBounds(minimumDistance: 800), interactionModes: .all) {
            Annotation(promise.destination, coordinate: CLLocationCoordinate2D(latitude: promise.latitude, longitude: promise.longitude)) {
                AnnotationCell()
                    .offset(x: 0, y: -10)
            }
        }
    }

    // 약속 제목
    var titleView: some View {
        Text(promise.promiseTitle)
            .font(.title)
            .padding(.top)
            .padding(.bottom)
            .bold()
    }
    // 약속 장소
    var destinationView: some View {
        Text("장소 : \(promise.destination)")
    }
    // 약속 날짜
    var dateView: some View {
        Text(("일시 : \(calculateDate(date: promise.promiseDate))"))
            .padding(.vertical, 3)
    }
    // 약속까지 남은 시간
    var remainingTimeView: some View {
        Text(formatRemainingTime())
            .foregroundStyle(.white)
            .font(.title).bold()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(statusColor)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.vertical, 12)
            .opacity(0.8)
    }
}

// MARK: - 프리뷰 크래시로 인해 프리뷰코드 주석처리
//  #Preview {
//    PromiseDetailView(promise:
//                        Promise(
//                            id: "",
//                            makingUserID: "3",
//                            promiseTitle: "지각파는 두더지 모각코",
//                            promiseDate: 1697101051.302136,
//                            destination: "서울특별시 종로구 종로3길 17",
//                            address: "",
//                            latitude: 0.0,
//                            longitude: 0.0,
//                            participantIdArray: ["3", "4", "5"],
//                            checkDoublePromise: false,
//                            locationIdArray: ["35", "34", "89"],
//                            penalty: 0))
// }
