//
//  PastPromiseView.swift
//  Zipadoo
//
//  Created by 이재승 on 2023/10/04.
//

import SwiftUI
import WidgetKit

struct PastPromiseView: View {
    @StateObject private var promise: PromiseViewModel = PromiseViewModel()
    @State private var isShownFullScreenCover: Bool = false
    
    let currentUser = AuthStore.shared.currentUser
    
    var body: some View {
        NavigationStack {
            ScrollView {

                if let loginUserID = currentUser?.id {
                    // 내가만든 약속 또는 참여하는 약속 불러오기
                    let filteredPromises = promise.fetchPastPromiseData.filter { promise in
                        return loginUserID == promise.makingUserID || promise.participantIdArray.contains(loginUserID)
                    }

                    // 약속 배열 값 존재하는지 확인.
                    if filteredPromises.isEmpty {
                        Text("지난 약속 내역이 없습니다.")
                        
                    } else {
                        VStack {
                            ForEach(filteredPromises) { promise in
                                NavigationLink {
//                                    PromiseDetailView(promise: promise)
                                    // 도착정보 보여주기
                                    ArriveResultView()
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(promise.promiseTitle)
                                                .font(.title)
                                                .fontWeight(.bold)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "map.fill")
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color.primary)
                                                .colorInvert()
                                                .padding(8)
                                                .background(Color.primary)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .shadow(color: .primary, radius: 1, x: 1, y: 1)
                                                        .opacity(0.3)
                                                    //
                                                )
                                        }
                                        .padding(.vertical, 10)
                                        
                                        Group {
                                            HStack {
                                                Image(systemName: "pin")
                                                Text("\(promise.destination)")
                                            }
                                            
                                            /// 저장된 promiseDate값을 Date 타입으로 변환
                                            let datePromise = Date(timeIntervalSince1970: promise.promiseDate)
                                            
                                            HStack {
                                                Image(systemName: "clock")
                                                Text("\(formatDate(date: datePromise))")
                                            }
                                            .padding(.bottom, 20)
                                            
                                            HStack {
                                                Text("6km")
                                                Spacer()
                                                
                                                Text("5,000원")
                                                    .fontWeight(.semibold)
                                                    .font(.title3)
                                            }
                                            .padding(.vertical, 10)
                                            
                                        }
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary).opacity(0.5)
                                        // 참여자의 ID를 통해 참여자 정보 가져오기
                                    }
                                    .padding()
                                    .overlay(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.zipadoo)
                                                .opacity(0.05)
                                                .shadow(color: .zipadoo, radius: 10, x: 5, y: 5)
                                        }
                                        
                                    )
                                    .foregroundStyle(Color.primary)
                                }
                                .padding()
                                
                            }
                        }
                    }
                }
                //            .ignoresSafeArea(.all)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .toolbar {
//                        ToolbarItem(placement: .topBarTrailing) {
//                            Button {
//                                // 삭제 코드 추가
//                            } label: {
//                               //
//                            }
//                            .fullScreenCover(isPresented: $isShownFullScreenCover, content: {
//                                AddPromiseView()
//                            })
//                        }
//                    }
            .onAppear {
                print(Date().timeIntervalSince1970)
                var calendar = Calendar.current
                calendar.timeZone = NSTimeZone.local
                let encoder = JSONEncoder()
                
                var widgetDatas: [WidgetData] = []
                
                for promise in promise.fetchPromiseData {
                    let promiseDate = Date(timeIntervalSince1970: promise.promiseDate)
                    let promiseDateComponents = calendar.dateComponents([.year, .month, .day], from: promiseDate)
                    let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                    
                    if promiseDateComponents == todayComponents {
                        // TODO: 도착 인원 수 파베 연동 후 테스트하기. 지금은 0으로!
                        let data = WidgetData(title: promise.promiseTitle, time: promise.promiseDate, place: promise.destination, arrivalMember: 0)
                        widgetDatas.append(data)
                    }
                }
                
                do {
                    let encodedData = try encoder.encode(widgetDatas)
                    
                    UserDefaults.shared.set(encodedData, forKey: "todayPromises")
                    
                    WidgetCenter.shared.reloadTimelines(ofKind: "ZipadooWidget")
                } catch {
                    print("Failed to encode Promise:", error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PastPromiseView()
    }
}
