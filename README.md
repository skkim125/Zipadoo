# <img width = "5%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 지파두 ReadMe

## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 프로젝트 소개
> 누군가와 약속에 대해 꼭 약속을 지키는 문화를 만들고자 하는 앱 (현재 서비스 종료)
<p align="center">
<img src="https://github.com/user-attachments/assets/13d0b912-8e6e-4720-a7e6-3fb9034a1904" width="19.5%"/>
<img src="https://github.com/user-attachments/assets/c2d0f140-7fd7-4df7-a268-bd1ccef284e1" width="19.5%"/>
<img src="https://github.com/user-attachments/assets/83645e97-d1f8-4545-ad48-40fe8f03d876" width="19.5%"/>
<img src="https://github.com/user-attachments/assets/7e3b89e7-d041-4849-9e98-b3f59cfa2b06" width="19.5%"/>
<img src="https://github.com/user-attachments/assets/64c9172b-0bf2-4b11-bf2c-0c1ca632186e" width="19.5%"/>
</p>
<br>

## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 프로젝트 환경
- 인원: iOS 7인 협업
- 프로젝트 기간: 2023.9.21 ~ 2023.10.24
- 출시 개발 기간: 2023.10.24 ~ 2023.12.15
- 유지 보수 기간: 2023.12.15 ~ 2024.02.28
- 개발 환경: Xcode 15
- 최소 버전: iOS 17.0
<br>

## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 기술 스택
- SwiftUI, MVVM + MVC
- CoreLocation, MapKit, Message, SafariServices, SwiftConcurrency, TipKit, UIImagePickerControllerDelegate, UIViewControllerRepresentable, UserNotification, WidgetKit
- Alamofire, Firebase, Lottie, SlidingTabView, SwiftLint, TossPayments
- Custom Modifier﹒Views, Singleton Pattern
<br>

## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 핵심 기능
- 약속 등록 및 수정
- 약속 시간 30분 전 ~ 약속 시간 3시간 후 동안 지도상 위치공유 및 남은 거리 확인
- 지난 약속 정보 및 결과 보기
- 친구 요청 및 관리
<br>

## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 주요 담당 기능
- 유저 관련 기능, 장소 검색 등을 위한 Singleton Pattern의 Store클래스와 특정 View에서 사용되는 ViewModel을 혼합한 MVVM형태로 구성
- 메인 HomeView & 약속 상세 View & 마이 View UI구성
  - Bottom Sheet를 CustomView로 구성하여 활용
- 약속 추가 View의 장소 추가 기능
  - MapReader의 convert 메서드와 CLGeocoder의 reverseGeocodeLocation 메서드를 활용하여 MapView를 탭할 시 해당 위치에 마커와 위치정보를 주소로 변환한 뷰가 표시되도록 구현
  - KakaoLocal API를 활용하여 장소 검색과 부가로 장소 정보를 확인할 수 있는 SafariView를 표시할 수 있도록 구현
  - CoreLocation을 활용하여 내 위치 주변의 장소 검색도 버튼 토글로 가능하도록 구현
- SwiftConcurrency를 사용한 회원 탈퇴 기능
  - Firebase의 비동기 메서드를 통해 현재 User에 대한 인증 진행 후 User와 관련된 모든 데이터와 친구관계인 유저의 친구목록에서 삭제되도록 구현
  - MainActor 프로퍼티 래퍼를 사용하여 메서드 동작 이후 UI 변경도 진행하도록 구현
<br>


## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 트러블 슈팅

****1. 장소 선택 기능 구현 중 기능 병합 이슈**** 

1) 문제 발생
	- 기존에 MapView를 터치하여 선택과 장소 검색 후 선택 각 기능을 담당하는 MapView를 표시하는 상단 탭바로 구현하였으나, 메모리를 많이 차지하는 MapView를 2개를 각각 배치하는 것은 리스크가 크다고 생각되어 하나의 뷰로 병합하는 과정이 필요
	- 또한 iOS 17의 MapView와 이전의 MapView의 호환이 불가능하기 때문에 하나의 버전의 MapView로 병합해야 하는 이슈 또한 존재

2) 해결 방법
	- iOS 17의 MapView에서는 GeometryReader와 유사한 기능을 제공하는 MapReader 컨테이너 뷰가 존재함을 확인
	- MapReader의 convert 메서드를 사용하여 지도 화면에서 특정 영역을 터치할 때, 터치한 화면 영역에 대한 좌표를 지도의 좌표로 변환
	- 변환된 좌표를 통해 CLGeocoder의 reverseGeocodeLocation를 활용하여 해당 위치의 주소를 텍스트로 표시

<details><summary> 구현한 코드
</summary>
  
```swift
  MapReader { reader in

				Map(position: $cameraPosition, scope: mapScope) {
															...
           }
	         .onTapGesture(perform: { screenCoord in
                        ...

                    selectedPlace = true
                    pinLocation = reader.convert(screenCoord, from: .local)
                    coordXXX = pinLocation?.latitude ?? 36.5665 // 터치한 장소의 위도
                    coordYYY = pinLocation?.longitude ?? 126.9880 // 터치한 장소의 경도
                            
                    // 변환한 위치값을 가져와 해당 위치에 대한 주소를 한국 버전으로 변환시켜줌
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(CLLocation(
                    latitude: pinLocation?.latitude ?? 36.5665,
                    longitude: pinLocation?.longitude ?? 126.9880),
                    preferredLocale: Locale(identifier: "ko_KR")) { placemarks, error in
                         if let placemark = placemarks?.first {
	                         address = [ placemark.locality, placemark.thoroughfare, placemark.subThoroughfare]
																			.compactMap { $0 }.joined(separator: " ")
		                    }
		                }

								...
           })
			...
}
```

</details>
<br>


****2. 회원 탈퇴 기능 구현 중 모든 항목이 삭제되지 않던 이슈**** 

1) 문제 발생
	- 앱 출시 심사에서 Reject 사유 중 하나로 회원 탈퇴에 대한 기능 구현 없음이 존재
	- 처음 구현 당시 회원 탈퇴를 선택한 유저를 Firebase Database에 존재하는 유저의 문서를 삭제하는 것으로 구현
	- 그러나 회원 탈퇴 이후 회원가입뷰로 이동하지 않는 이슈와 탈퇴한 계정의 이메일로 다시 회원가입이 불가능한 이슈 발생
	- 또한 회원 탈퇴한 유저가 친구인 유저의 친구목록에도 그대로 존재하게 되어 친구목록 또는 약속 추가 시 친구리스트에 표시되는 이슈 발생

2) 해결 방법
	- 단순히 Firebase Database에 존재하는 유저의 문서를 삭제하는 것 뿐만이 아닌, 모든 문서에서 남아있는 유저의 데이터를 삭제를 해주어야 한다는 것을 알 수 있었음
	- 회원 탈퇴시 유저와 관련된 모든 데이터(유저이메일의 콜렉션, 해당유저와 친구인 유저들의 목록문서에 있는 해당 유저의 id, authentication에 있는 해당 유저의 이메일)을 삭제함으로 완전한 회원탈퇴 기능 구현

<details><summary> 구현한 코드
</summary>
  
```swift
  func deleteAccount() async throws {
        guard let currentUid = userSession?.uid else { return }
        
        // 해당 유저 파이어베이스 데이터베이스의 문서를 삭제
        try await dbRef.document(currentUid).delete()
        
        // 해당 유저의 유저이메일 콜렉션 삭제
        let userEmailRef = Firestore.firestore().collection("User email")
        let userDocuments = try await userEmailRef.whereField("userId", isEqualTo: currentUid).getDocuments()
        
        for document in userDocuments.documents {
            try await document.reference.delete()
        }
        
        // 해당 유저와 친구사이인 유저들의 친구목록 문서에서 해당유저 id 삭제
        let friendsArray = try await dbRef.whereField("friendsIdArray", isEqualTo: currentUid).getDocuments()
        
        for document in friendsArray.documents {
            try await document.reference.delete()
        }
        
        // authentication에 있는 해당유저의 이메일 삭제
        try await Auth.auth().currentUser?.delete()
        
        // 섹션 초기화
        self.userSession = nil
        self.currentUser = nil
        
        print("회원 정보 삭제 성공")
    }
```
</details>
<br>



## <img width = "3%" src = "https://github.com/APPSCHOOL3-iOS/final-zipadoo/assets/102401977/6785967f-2630-4cd4-95ab-634833cd2d51"/> 회고

****- 효율적으로 진행되었던 협업****
- 해당 프로젝트를 계획하면서 팀원들과 커밋 컨벤션을 세워 Git Flow 전략을 실천하였고, 발생한 이슈에 대해 적극적인 커뮤니케이션을 진행하면서 빠르게 이슈를 해결하며 효율적인 협업을 진행할 수 있었습니다.

****- MVVM 디자인 패턴****
- Store과 ViewModel을 혼합한 MVVM을 구현하도록 노력하였는데, 디자인 패턴에 이해도가 부족한 상태에서 디자인 패턴을 구현하다보니 통일성 있는 코드를 작성하지 못하였던 것 같습니다. 다음 프로젝트를 진행할 때에는 진행 전 디자인 패턴에 대한 학습을 충분히 진행한 다음 명확한 규칙과 기준을 가지고 설계해나가야겠다고 느꼈습니다.

****- 새로운 기술과 최소 버전에 대한 고려****
- 프로젝트 당시 WWDC 이후 발표되었던 WidgetKit, SwiftUI의 MapKit 등 흥미로운 프레임워크를 사용하며 흥미롭게 개발을 진행하였지만, 새로운 프레임워크에 대한 정보가 부족하여 실제 구현에 어려움을 겪었던 시간도 존재했습니다.
- 이후 프로젝트에서 새로운 기술을 사용하려고 할 때에는 이러한 경험을 바탕으로 신중히 고려한 이후 도입해야 함을 인지하고, 만약 도입하려고 한다면 충분한 사전 학습을 진행하도록 하여 개발 리스크를 줄여나가려 합니다.
- 그리고 프로젝트 당시 iOS 17이 공개되었기 때문에 iOS 16을 사용하는 유저가 많았을 시점이었기에, 항상 프로젝트를 진행하기 전 최소 버전 지원에 대한 고려도 충분히 진행하려고 합니다.
<br>


