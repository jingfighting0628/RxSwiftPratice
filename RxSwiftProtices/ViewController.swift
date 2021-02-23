//
//  ViewController.swift
//  RxSwiftProtices
//
//  Created by liuningbo on 2021/2/15.
//

import UIKit
import RxSwift
import RxRelay
import os
import SwiftUI
enum MyError: Error {
case anError
}
struct Student {
let score: BehaviorSubject<Int>
    
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        example(of: "just, of, from") {
           // 1
            let one = 1
            let two = 2
            let three = 3
            // 2
            /*
             在上面的代码中，
             您：1.定义将在以下示例中使用的整数常量。
                2.使用Just方法和一个整数常量创建一个Int类型的可观察序列。
                just方法被恰当地命名，因为它所做的只是创建一个仅包含单个元素的可观察序列。 这是Observable的静态方法。 但是，在Rx中，方法称为“运算符”。在您当中，老鹰眼的人可能会猜出下一步要检出哪个运算符
             */
            let observable = Observable<Int>.just(one)
            //of运算符具有可变参数，Swift可以基于该参数推断Observable的类型
            let observable2 = Observable<Int>.of(one,two,three)
            let observable3 = Observable.of([one, two, three])
            //from运算符可从类型化元素数组创建可观察的单个元素
            let observable4 = Observable.from([one,two,three])
            
                
        }
        
        example(of: "subscribe"){
            let one = 1
            let two = 2
            let three = 3
            
            let observable = Observable.of(one,two,three)
            //事件具有元素属性。 这是一个可选值，因为只有下一个事件才包含一个元素。 因此，如果元素不是nil，则可以使用可选的绑定来对其展开
            /*
            observable.subscribe { event in
                if let element = event.element {
                    print(element)
                }
            }
            */
            //对于可观察到的每种事件，都有一个订阅操作符：下一个，错误和完成
            observable.subscribe(onNext:{element in
                print(element)
            })
        }
        
        example(of: "empty") {
          
            let observable = Observable<Void>.empty()
            
            observable.subscribe(onNext:{
                element in
                
                print(element)
            },
            onCompleted:{
                
                print("Completed")
            })
            
        }
        example(of: "nerver") {
          
            let observable = Observable<Void>.never()
            
            observable.subscribe(onNext:{
                element in
                
                print(element)
            },
            onCompleted:{
                
                print("Completed")
            })
            
        }
        
        example(of: "range") {
        // 1
        let observable = Observable<Int>.range(start: 1, count: 10)
         observable
         .subscribe(onNext: { i in
        // 2
        let n = Double(i)
        let fibonacci = Int(
         ((pow(1.61803, n) - pow(0.61803, n)) /
        2.23606).rounded()
         )
           print(fibonacci)
         })
        }
        
        example(of: "dispose") {
        // 1
        let observable = Observable.of("A", "B", "C")
        // 2
        let subscription = observable.subscribe { event in
        // 3
        print(event)
         }
        }
        
        example(of: "create") {
            let disposeBag = DisposeBag()
            Observable<String>.create { observer in
            // 1
             observer.onNext("1")
             observer.onError(MyError.anError)
            // 2
             observer.onCompleted()
            // 3
             observer.onNext("?")
            // 4
            return Disposables.create()
            }
            .subscribe(
                onNext: { print($0) },
                onError: { print($0) },
                onCompleted: { print("Completed") },
                onDisposed: { print("Disposed") }
               )
               .disposed(by: disposeBag)
            
            
            example(of: "deferred") {
            let disposeBag = DisposeBag()
            // 1
            var flip = false
            // 2
            let factory: Observable<Int> = Observable.deferred {
            // 3
             flip.toggle()
            // 4
            if flip {
            return Observable.of(1, 2, 3)
             } else {
            return Observable.of(4, 5, 6)
             }
             }
            }
            
            example(of: "Single") {
            // 1
            let disposeBag = DisposeBag()
            // 2
            enum FileReadError: Error {
            
            case fileNotFound, unreadable, encodingFailed
             }
            // 3
            func loadText(from name: String) -> Single<String> {
            // 4
               return Single.create { single in
                
                let disposable = Disposables.create()
                // 2
                guard let path = Bundle.main.path(forResource: name, ofType:
                "txt") else {
                 //single(.error(FileReadError.fileNotFound))
                return disposable
                }
                // 3
                guard let data = FileManager.default.contents(atPath: path) else
                {
                 //single(.error(FileReadError.unreadable))
                return disposable
                }
                // 4
                guard let contents = String(data: data, encoding: .utf8) else {
                 //single(.error(FileReadError.encodingFailed))
                return disposable
                }
                // 5
                single(.success(contents))
                return disposable
                
                
             }
             }
            }
           
            
            
            
        }
        
        example(of: "PublishSubject") {
            let subject = PublishSubject<String>()
            subject.on(.next("Is anyone listening?"))
            let subscriptionOne = subject
             .subscribe(onNext: { string in
            print(string)
             })
            subject.on(.next("1"))
            subject.onNext("2")//快捷语法
            let subscriptionTwo = subject
             .subscribe { event in
            print("2)", event.element ?? event)
             }
            subject.onNext("3")
            subscriptionOne.dispose()
            subject.onNext("4")
            /*
             1.使用方便的on（.completed）方法将一个已完成的事件添加到主题上。 这终止了对象的可观察序列。
                2.在主题上添加另一个元素。 不过，由于主题已经终止，因此不会发出和打印。
                3.处置订阅。
                4.订阅主题，这次将其一次性用品添加到处理袋中。
                也许新订户3）将使主题重新投入使用吗？ 不，但是您仍然可以重播完成的事件
             */
            // 1
            subject.onCompleted()
            // 2
            subject.onNext("5")
            // 3
            subscriptionTwo.dispose()
            let disposeBag = DisposeBag()
            // 4
            subject
             .subscribe {
            print("3)", $0.element ?? $0)
             }
             .disposed(by: disposeBag)
            subject.onNext("?")
            
        }
        example(of: "BehaviorSubject") {
        // 4
        let subject = BehaviorSubject(value: "Initial value")
        let disposeBag = DisposeBag()
            subject.onNext("X")
            subject
             .subscribe {
                self.printSomething(label: "1)", event: $0)
             }
             .disposed(by: disposeBag)
            
            subject.onError(MyError.anError)
            // 2
            subject
             .subscribe {
                self.printSomething(label: "2)", event: $0)
             }
             .disposed(by: disposeBag)
        }
        
        example(of: "ReplaySubject") {
            /*
             1.创建一个缓冲区大小为2的新重放主题。重放类型使用create（bufferSize :)类型方法进行初始化。
                2.在主题上添加三个元素。
                3.创建对该主题的两个订阅。
                这两个订户都将重播最近的两个元素；  1永远不会发出，因为在订阅任何内容之前，将2和3添加到具有2缓冲区大小的重播主题上
             */
        // 1
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        let disposeBag = DisposeBag()
        // 2
         subject.onNext("1")
         subject.onNext("2")
         subject.onNext("3")
        // 3
         subject
         .subscribe {
            self.printSomething(label: "1)", event: $0)
         }
         .disposed(by: disposeBag)
            
            subject
             .subscribe {
                self.printSomething(label: "2)", event: $0)
             }
             .disposed(by: disposeBag)
            /*
             使用此代码，您可以在主题上添加另一个元素，然后为其创建新的订阅。 前两个订阅将正常接收该元素，因为在将新元素添加到主题时它们已经被订阅了，而新的第三个订阅者将向其重播最后两个缓冲的元素
             */
            subject.onNext("4")
            /*
             重播主题因错误而终止，它将重新发送给新订阅者-您之前已学过。 但是缓冲区也仍然悬而未决，因此在重新发出stop事件之前，它也会被重放给新的订户
             */
            subject.onError(MyError.anError)
            //添加错误后立即添加以下代码行：
            /*
             通常不需要像这样在重放主题上显式调用dispose（）。 如果您已将订阅添加到处理包中，那么当所有者（例如视图控制器或视图模型）被释放时，所有内容都将被处理并释放
             */
            subject.dispose()
            subject
             .subscribe {
                self.printSomething(label: "3)", event: $0)
             }
             .disposed(by: disposeBag)
        }
        example(of: "PublishRelay") {
            let relay = PublishRelay<String>()
            let disposeBag = DisposeBag()
            relay.accept("Knock knock, anyone home?")
            relay
             .subscribe(onNext: {
            print($0)
             })
             .disposed(by: disposeBag)
            relay.accept("1")
            //无法将错误或已完成的事件添加到PublishRelay上
            //relay.accept(MyError.anError)
            //relay.onCompleted()
        }
        example(of: "BehaviorRelay") {
            /*
             1.创建一个具有初始值的行为中继。 可以推断中继的类型，但是您也可以将类型明确声明为BehaviorRelay <String>（值：“初始值”）。
                2.在继电器上添加一个新元素
                3、订阅中继。
             */
        // 1
        let relay = BehaviorRelay(value: "Initial value")
        let disposeBag = DisposeBag()
        // 2
         relay.accept("New initial value")
        // 3
         relay
         .subscribe {
            self.printSomething(label: "1)", event: $0)
         }
         .disposed(by: disposeBag)
            // 1
            relay.accept("1")
            // 2
            relay
             .subscribe {
                self.printSomething(label: "2)", event: $0)
             }
             .disposed(by: disposeBag)
            // 3
            relay.accept("2")
            /*
             1.在继电器上添加一个新元素。
                2.创建中继的新订阅。
                3.在继电器上添加另一个新元素。
                现有订阅1）接收添加到中继上的新值1。 新订阅在订阅时会获得相同的价值，因为它是最新的价值。 当两个订阅添加到中继中时，两个订阅都会收到2
             */
            print(relay.value)
        }
        
        example(of: "ignoreElements") {
        // 1
        let strikes = PublishSubject<String>()
        let disposeBag = DisposeBag()
        // 2
         strikes
         .ignoreElements()
         .subscribe { _ in
            print("You're out!")
         }
         .disposed(by: disposeBag)
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onCompleted()
            //可能会注意到ignoreElements实际上返回了Completable，这很有意义，因为它只会发出完成事件或错误事件。
           
        }
        example(of: "elementAt") {
        //有时您可能只想处理可观察对象发出的第n个（常规）元素，例如第三次罢工。 为此，可以使用elementAt，它获取要接收的元素的索引，而忽略其他所有内容。 在大理石图中，elementAt传递的索引为2，因此它仅允许通过第三个元素
        // 1
        let strikes = PublishSubject<String>()
        let disposeBag = DisposeBag()
        // 2
         strikes
         .elementAt(2)
         .subscribe(onNext: { _ in
        print("You're out!")
         })
         .disposed(by: disposeBag)
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onNext("X")
        }
        
        example(of: "filter") {
        /*
           1.创建一个可观察值的一些预定义整数。
           2.使用filter运算符可以应用条件约束，以防止奇数通过。
           3.您订阅并打印出通过过滤谓词的元素。
            应用此过滤器的结果是仅打印偶数：
        */
        let disposeBag = DisposeBag()
        // 1
        Observable.of(1, 2, 3, 4, 5, 6)
        // 2
         .filter { $0.isMultiple(of: 2) }
        // 3
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "skip") {
            /*
             1.创建一个可观察的字母。
             2.使用跳过跳过前三个元素并订阅下一个事件。
                跳过前三个元素后，仅打印D，E和F
             */
        let disposeBag = DisposeBag()
        // 1
        Observable.of("A", "B", "C", "D", "E", "F")
        // 2
         .skip(3)
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "skipWhile") {
        /*
          1.创建一个可观察的整数。
          2.将skipWhile与断言一起使用，该断言会跳过元素，直到发出奇数整数为止
        */
        let disposeBag = DisposeBag()
        // 1
        Observable.of(2, 2, 3, 4, 4)
        // 2
         .skipWhile { $0.isMultiple(of: 2) }
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "skipUntil") {
            
        /*
          1.创建一个主题以对要使用的数据进行建模，并创建另一个主题作为触发器。
          2.使用skipUntil并传递触发主题。 当触发器发出时，skipUntil停止跳过
         */
        let disposeBag = DisposeBag()
        // 1
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        // 2
         subject
         .skipUntil(trigger)
         .subscribe(onNext: {
           print($0)
         })
         .disposed(by: disposeBag)
            subject.onNext("A")
            subject.onNext("B")
            //由于您正在跳过，因此未打印任何内容。 现在将新的下一个事件添加到触发器
            trigger.onNext("X")
            //这将导致skipUntil停止跳过。 从这一点开始，所有元素都被允许通过。 在主题上添加另一个下一个事件
            subject.onNext("C")
            
        }
        
        example(of: "take") {
            //1.创建一个可观察的整数。
            //2.使用take获取前3个元素
        let disposeBag = DisposeBag()
        // 1
        Observable.of(1, 2, 3, 4, 5, 6)
        // 2
         .take(3)
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        
        example(of: "takeWhile") {
            /*
               1.创建一个可观察的整数。
                2.使用枚举运算符获取包含发出的每个元素的索引和值的元组。
                3.使用takeWhile运算符，并将元组分解为单个参数。
                4.传递一个将带元素的谓词，直到条件失败为止。
                5.使用地图（其工作原理与Swift标准库地图相同）进入到达takeWhile返回的元组并获取元素。
                6.订阅并打印下一个元素
             */
        let disposeBag = DisposeBag()
        // 1
        Observable.of(2, 2, 4, 4, 6, 6)
        // 2
         .enumerated()
        // 3
         .takeWhile { index, integer in
        // 4
         integer.isMultiple(of: 2) && index < 3
         }
        // 5
         .map(\.element)
        // 6
         .subscribe(onNext: {
           print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "takeUntil") {
        /*
           1.创建一个可观察的连续整数。
           2.使用具有包含行为的takeUntil运算符。
           这段代码可以打印出直至通过谓词的元素，包括该谓词
        */
        let disposeBag = DisposeBag()
        // 1
        Observable.of(1, 2, 3, 4, 5)
        // 2
         .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
            //现在，将行为从.inclusive更改为.exclusive，然后再次运行Playground。 这次，排除通过谓词的元素
            Observable.of(1, 2, 3, 4, 5)
            // 2
             .takeUntil(.exclusive) { $0.isMultiple(of: 4) }
             .subscribe(onNext: {
            print($0)
             })
             .disposed(by: disposeBag)
        }
        
        example(of: "takeUntil trigger") {
            /*
             1.创建主要主题和触发主题。
                2.使用takeUntil，传递将触发takeUntil停止发出的触发器。
                3.在主题上添加几个元素
             */
          let disposeBag = DisposeBag()
        // 1
          let subject = PublishSubject<String>()
          let trigger = PublishSubject<String>()
        // 2
         subject
         .takeUntil(trigger)
         .subscribe(onNext: {
            print($0)
         })
         .disposed(by: disposeBag)
        // 3
         subject.onNext("1")
         subject.onNext("2")
            //现在在触发器上添加一个元素，然后在主题上添加另一个元素：
            //X停止拍摄，因此不允许3通过并且不再打印任何内容。
            trigger.onNext("X")
            subject.onNext("3")
        }
        
        example(of: "distinctUntilChanged") {
            /*
             使用此代码的操作：1.创建一个可观察的字母。
                2.使用distinctUntilChanged防止顺序重复项通过。
             distinctUntilChanged运算符仅防止连续重复，因此第二个A和第二个B与其前一个元素相等，因此被阻止。 但是，允许使用第三个A，因为它不等于其前一个元素
             */
        let disposeBag = DisposeBag()
        // 1
        Observable.of("A", "A", "B", "B", "A")
        // 2
         .distinctUntilChanged()
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "distinctUntilChanged(_:)") {
            /*
             1.创建一个数字格式化程序以拼出每个数字。
                2.创建一个可观察的NSNumbers而不是Ints，这样在接下来使用格式化程序时不必转换整数。
                3.使用distinctUntilChanged（_ :)，它采用一个谓词闭包来接收每个顺序的元素对。
                4.使用guard来有条件地绑定用空格隔开的元素组件，否则返回false。
                5.迭代第一个数组中的每个单词，然后查看它是否包含在第二个数组中。
                6.根据您提供的比较逻辑，订阅并打印出被认为是不同的元素。
                结果，仅打印出不同的整数，并考虑到在每对整数中，一个不包含另一个整数
             */
            //当您要明确防止不符合Equatable的类型重复时，distinctUntilChanged（_ :)运算符也很有用
            let disposeBag = DisposeBag()
            // 1
            let formatter = NumberFormatter()
             formatter.numberStyle = .spellOut
            // 2
            Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
            // 3
             .distinctUntilChanged { a, b in
            // 4
            guard
            let aWords = formatter
             .string(from: a)?
             .components(separatedBy: " "),
            let bWords = formatter
             .string(from: b)?
             .components(separatedBy: " ")
             else {
             return false
             }
            var containsMatch = false
            // 5
                for aWord in aWords where bWords.contains(aWord) {
                 containsMatch = true
                break
                 }
                return containsMatch
                 }
                // 4
                 .subscribe(onNext: {
                print($0)
                 })
                 .disposed(by: disposeBag)
        }
        
        //Sharing subscriptions
        
        var start = 0
        func getStartNumber() -> Int {
         start += 1
        return start
        }
        let numbers = Observable<Int>.create { observer in
        let start = getStartNumber()
         observer.onNext(start)
         observer.onNext(start+1)
         observer.onNext(start+2)
         observer.onCompleted()
        return Disposables.create()
        }
        numbers
         .subscribe(
         onNext: { el in
        print("element [\(el)]")
         },
         onCompleted: {
        print("-------------")
         }
         )
        numbers
         .subscribe(
         onNext: { el in
        print("element [\(el)]")
         },
         onCompleted: {
        print("-------------")
         }
         )
        
        example(of: "toArray") {
        let disposeBag = DisposeBag()
        // 1
        Observable.of("A", "B", "C")
        // 2
         .toArray()
         .subscribe(onSuccess: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        example(of: "map") {
        let disposeBag = DisposeBag()
        // 1
        let formatter = NumberFormatter()
         formatter.numberStyle = .spellOut
        // 2
        Observable<Int>.of(123, 4, 56)
        // 3
         .map {
         formatter.string(for: $0) ?? ""
         }
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        example(of: "enumerated and map") {
            /*
             1.创建一个可观察的整数。
                2.使用枚举产生每个元素及其索引的元组对。
                3.使用map，然后将元组分解为单独的参数。 如果元素的索引大于2，则将其乘以2并返回；否则 否则，原样返回。
                4.订阅并打印发射的元素
             */
        let disposeBag = DisposeBag()
        // 1
        Observable.of(1, 2, 3, 4, 5, 6)
        // 2
         .enumerated()
        // 3
         .map { index, integer in
         index > 2 ? integer * 2 : integer
         }
        // 4
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "compactMap") {
        let disposeBag = DisposeBag()
        // 1
        Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
        // 2
         .compactMap { $0 }
        // 3
         .toArray()
        // 4
         .map { $0.joined(separator: " ") }
        // 5
         .subscribe(onSuccess: {
        print($0)
         })
         .disposed(by: disposeBag)
        }
        
        example(of: "flatMap") {
            /*
             1.创建两个Student实例，分别是laura和charlotte。
                2.创建类型为Student的源主题。
                3.您使用flatMap进入学生主题并投影其分数。
                4.您打印出订阅中的下一个事件元素
             */
        let disposeBag = DisposeBag()
        // 1
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        // 2
        let student = PublishSubject<Student>()
        // 3
         student
         .flatMap {
         $0.score
         }
        // 4
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
            student.onNext(laura)
            laura.score.onNext(85)
            student.onNext(charlotte)
            laura.score.onNext(95)
            charlotte.score.onNext(100)
        }
        
        example(of: "flatMapLatest") {
        let disposeBag = DisposeBag()
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        let student = PublishSubject<Student>()
         student
         .flatMapLatest {
         $0.score
         }
         .subscribe(onNext: {
        print($0)
         })
         .disposed(by: disposeBag)
         student.onNext(laura)
         laura.score.onNext(85)
         student.onNext(charlotte)
        //1.在此处更改laura的分数将无效。 它不会被打印出来。 这是因为对于charlotte，flatMapLatest切换到了最新的observable，所以95不会打印
        // 1
         laura.score.onNext(95)
         charlotte.score.onNext(100)
            
        }
        
        example(of: "materialize and dematerialize") {
            //有时您可能想将一个可观察的事件转换为其事件的可观察的事件。 当您无法控制具有可观察属性的可观察对象，并且希望处理错误事件以避免终止外部序列时
            /*
            1、使用flatMapLatest创建一个studentScore可观察者，以进入该学生可观察者并访问其分数可观察属性。
                2.订阅并打印出每个乐谱。
                3.在当前学生中添加分数，错误和另一个分数。
                4.将第二个夏洛特添加到可观察的学生上。 因为您使用了flatMapLatest，所以它将切换到该新学生并订阅她的分数
             */
        // 1
        enum MyError: Error {
        case anError
         }
        let disposeBag = DisposeBag()
        // 2
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 100))
        let student = BehaviorSubject(value: laura)
            
            // 1
            let studentScore = student
             .flatMapLatest {
             $0.score
             }
            // 2
            studentScore
             .subscribe(onNext: {
            print($0)
             })
             .disposed(by: disposeBag)
            // 3
             laura.score.onNext(85)
            //无法处理此错误。studentScore可观察终止，外部学生可观察终止
             laura.score.onError(MyError.anError)
            ////无法处理此错误。studentScore可观察终止，外部学生可观察终止
             laura.score.onNext(90)
            // 4
             student.onNext(charlotte)
            
        }
        
        example(of: "materialize and dematerialize ") {
            
        // 1
        enum MyError: Error {
        case anError
         }
        let disposeBag = DisposeBag()
        // 2
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 100))
        let student = BehaviorSubject(value: laura)
            
            // 与上面例子不同的是将studentScore实现更改为以下内容：
            /*
            let studentScore = student
             .flatMapLatest {
             $0.score
             }
            */
            let studentScore = student
             .flatMapLatest {
             $0.score.materialize()
             }
            // 2
            studentScore
             .subscribe(onNext: {
            print($0)
             })
             .disposed(by: disposeBag)
            // 3
             laura.score.onNext(85)
            //由于materialize运算符把错误包装到可观察对象中，可以继续打印
             laura.score.onError(MyError.anError)
            //
             laura.score.onNext(90)
            // 4
             student.onNext(charlotte)
            
        }
        
        example(of: "materialize and dematerialize ") {
            
        // 1
        enum MyError: Error {
        case anError
         }
        let disposeBag = DisposeBag()
        // 2
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 100))
        let student = BehaviorSubject(value: laura)
            
            let studentScore = student
             .flatMapLatest {
             $0.score.materialize()
             }
            // 2
            //与上面的例子不同的是将订阅更改为以下内容
            /*
            studentScore
             .subscribe(onNext: {
            print($0)
             })
             .disposed(by: disposeBag)
             */
            
            studentScore
            // 1
             .filter {
            guard $0.error == nil else {
            print($0.error!)
            return false
             }
            return true
             }
            // 2
             .dematerialize()
             .subscribe(onNext: {
            print($0)
             })
             .disposed(by: disposeBag)
            //与上面的例子不同的是将订阅更改为以上内容
            
            
            // 3
             laura.score.onNext(85)
            //由于materialize运算符把错误包装到可观察对象中，可以继续打印
             laura.score.onError(MyError.anError)
            //
             laura.score.onNext(90)
            // 4
             student.onNext(charlotte)
            
        }
        
        example(of: "ShareReplay")
        {
            let disposeBag = DisposeBag()
               
            let observable = Observable.just("🤣").map{print($0)}.share(replay: 1,scope: .whileConnected)
                
            observable.subscribe{print("Even:\($0)")}.disposed(by: disposeBag)
            observable.subscribe{print("Even:\($0)")}.disposed(by: disposeBag)
            
        }
        //第九章
        example(of: "startWith") {
        // 1
        let numbers = Observable.of(2, 3, 4)
        // 2
        let observable = numbers.startWith(1)
            _ = observable.subscribe(onNext: { value in
        print(value)
         })
        }
        
        example(of: "Observable.concat") {
            /*
             Observable.concat（_ :)静态方法采用可观察变量的有序集合（即数组）或可变变量的可观察变量列表。 它订阅集合的第一个序列，中继其元素，直到完成为止，然后移至下一个序列。 重复该过程，直到已使用了集合中的所有可观测值。 如果内部可观察对象在任何时候发出错误，则串联的可观察对象又将发送错误并终止
             */
        // 1
        let first = Observable.of(1, 2, 3)
        let second = Observable.of(4, 5, 6)
        // 2
        let observable = Observable.concat([first, second])
         observable.subscribe(onNext: { value in
        print(value)
         })
        }
        
        example(of: "concat") {
        let germanCities = Observable.of("Berlin", "Münich",
        "Frankfurt")
        let spanishCities = Observable.of("Madrid", "Barcelona",
        "Valencia")
        let observable = germanCities.concat(spanishCities)
        _ = observable.subscribe(onNext: { value in
        print(value)
         })
        }
        
        example(of: "concatMap") {
        /*
          1.准备两个序列，分别产生德语和西班牙语城市名称。
          2、具有一个发出国家名称的序列，每个序列依次映射到该国家发出城市名称的序列
          3.在开始考虑下一个国家之前，输出给定国家的完整序列。
          现在您知道了如何将序列附加在一起，是时候继续并组合多个序列中的元素了
             */
        // 1
        let sequences = [
        "German cities": Observable.of("Berlin", "Münich",
        "Frankfurt"),
        "Spanish cities": Observable.of("Madrid", "Barcelona",
        "Valencia")
         ]
        // 2
        let observable = Observable.of("German cities", "Spanishcities")
         .concatMap { country in sequences[country] ?? .empty() }
        // 3
        _ = observable.subscribe(onNext: { string in
        print(string)
         })
        }
        
        example(of: "merge") {
        // 1
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        //接下来，创建一个可观察的可观察源-就像Inception！ 为简单起见，将其固定列为两个主题
        let source = Observable.of(left.asObservable(),
            right.asObservable())
        //接下来，创建一个可从两个主题观察到的合并，以及订阅以打印它发出的值：
        let observable = source.merge()
        _ = observable.subscribe(onNext: { value in
            print(value)
        })
        //然后，您需要随机选择值并将其推入任一可观察值。 循环使用完leftValues和rightValues数组中的所有值，然后退出
        // 4
        var leftValues = ["Berlin", "Munich", "Frankfurt"]
        var rightValues = ["Madrid", "Barcelona", "Valencia"]
        repeat {
            switch Bool.random() {
            case true where !leftValues.isEmpty:
            left.onNext("Left: " + leftValues.removeFirst())
            case false where !rightValues.isEmpty:
            right.onNext("Right: " + rightValues.removeFirst())
            default:
            break
             }
             } while !leftValues.isEmpty || !rightValues.isEmpty
        //完成操作后的最后一点是在左右PublishSubjects上调用onCompleted：
            // 5
            left.onCompleted()
            right.onCompleted()
            
            /*
             可以观察到的merge（）订阅它所接收的每个序列，并在元素到达时立即发出它们-没有预定义的顺序。
                您可能想知道何时以及如何完成merge（）。 好问题！ 与RxSwift中的所有内容一样，规则定义明确：•merge（）在其源序列完成并且所有内部序列都完成之后完成。
                •内部序列的完成顺序无关紧要。
                •如果任何序列发出错误，则可观察到的merge（）立即中继错误，然后终止。
                花一点时间看一下代码。 请注意，merge（）带有一个可观察的源，它本身发出元素类型的可观察序列。 这意味着您可以发送许多序列供merge（）订阅！
                要限制一次订阅的序列数，可以使用merge（maxConcurrent :)。 此变体会一直订阅传入的序列，直到达到maxConcurrent限制。 之后，它将传入的可观察对象放入队列。 一旦活动序列之一完成，它将按顺序订阅它们
             */
            
            
        }
        
        example(of: "combineLatest") {
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        //接下来，创建一个结合了两个来源的最新值的可观察值。 不用担心 完成所有内容的添加后，您将了解代码的工作原理
            // 1
            let observable = Observable.combineLatest(left, right) {
             lastLeft, lastRight in
            "\(lastLeft) \(lastRight)"
             }
            _ = observable.subscribe(onNext: { value in
            print(value)
             })
            //现在添加以下代码以开始将值推入可观察对象：
            // 2
            print("> Sending a value to Left")
            left.onNext("Hello,")
            print("> Sending a value to Right")
            right.onNext("world")
            print("> Sending another value to Right")
            right.onNext("RxSwift")
            print("> Sending another value to Left")
            left.onNext("Have a good day,")
            //最后，别忘了完成两个主题并关闭示例（of :)尾随闭包
            left.onCompleted()
            right.onCompleted()
            /*
             关于此示例的一些值得注意的要点：
             1、您可以使用闭包来组合可观察变量，该闭包接收每个序列的最新值作为参数。 在此示例中，组合是左右两个值的连接字符串。 您可能还需要其他任何内容，因为组合的observable发出的元素类型是闭包的返回类型。 实际上，这意味着您可以组合异构类型的序列。 这是允许这样做的罕见的核心运算符之一，另一个是您很快就会了解的withLatestFrom（_ :)。
            2.在每个可观察对象发出一个值之前，什么都不会发生。 此后，每次发出一个新值时，闭包都会收到每个可观察值的最新值并产生其结果
             
             */
            
            
        }
        
        example(of: "combine user choice and value") {
        //本示例演示了当用户设置更改时屏幕值的自动更新。 考虑一下您将通过这种模式删除的所有手动更新
        let choice: Observable<DateFormatter.Style> =
        Observable.of(.short, .long)
        let dates = Observable.of(Date())
            
        let observable = Observable.combineLatest(choice, dates) {
         format, when -> String in
        let formatter = DateFormatter()
         formatter.dateStyle = format
        return formatter.string(from: when)
         }
        _ = observable.subscribe(onNext: { value in
        print(value)
         })
        }
        
        example(of: "zip") {
        
        enum Weather {
        case cloudy
        case sunny
         }
        let left: Observable<Weather> = Observable.of(.sunny, .cloudy,
        .cloudy, .sunny)
        let right = Observable.of("Lisbon", "Copenhagen", "London",
        "Madrid", "Vienna")
        //然后创建两个源的压缩可观察值。 请注意，您使用的是zip（_：_：resultSelector :)变体
            let observable = Observable.zip(left, right) { weather, city
            in
            return "It's \(weather) in \(city)"
             }
            _ = observable.subscribe(onNext: { value in
            print(value)
             })
            
            /*
             这是zip（_：_：resultSelector :)为您完成的工作：
             •订阅了您提供的可观察对象。
             •等待每个发出新值。
             •用两个新值称您的闭合。
               您是否注意到维也纳没有出现在输出中？ 这是为什么？
              解释在于zip运算符的工作方式。 他们将每个可观察值的每个下一个值配对在相同的逻辑位置（第一个与第一个，第二个与第二个，等等）。 这意味着，如果在下一个逻辑位置没有一个内部可观察值的下一个值可用（即，因为它已完成，如上面的示例中所示），则zip将不再发出任何内容。 这被称为索引排序，这是一种以步调顺序遍历序列的方法。 但是，尽管zip可能会尽早停止发布值，但它本身不会完成，直到所有内部可观察到的内容都完成为止，以确保每个人都可以完成工作
             
             */
            //注意：Swift也有一个zip（_：_ :)集合运算符。 它使用两个集合中的项目创建一个新的元组集合。 但这是其唯一的实现。  RxSwift提供了两个到八个可观察对象的变体，以及集合的一个变体
        }
        
        example(of: "withLatestFrom") {
        /*
             1.创建两个主题，模拟按钮的点击和文本字段输入。 由于按钮不包含实际数据，因此可以将Void用作元素类型。
              2、当button发出一个值时，忽略它，而是发出从模拟文本字段接收到的最新值。
              3.模拟到文本字段的连续输入，这是通过两次连续的按钮轻击完成的。
               简单明了！  withLatestFrom（_ :)在您希望从可观察对象发出当前（最新）值的所有情况下很有用，但仅当发生特定触发器时才有用
        */
        // 1
        let button = PublishSubject<Void>()
        let textField = PublishSubject<String>()
        // 2
        //let observable = button.withLatestFrom(textField)
        let observable = textField.sample(button)
        _ = observable.subscribe(onNext: { value in
        print(value)
         })
        // 3
         textField.onNext("Par")
         textField.onNext("Pari")
         textField.onNext("Paris")
         button.onNext(())
            textField.onNext("Paris1111")
         button.onNext(())
        //注意：不要忘记withLatestFrom（_ :)将可观察的数据作为参数，而sample（_ :)将触发器可观察的参数作为参数。 这很容易成为错误的根源-请当心！button是触发器 textField是观察的数据
            
            
        }
        example(of: "amb") {
            /*
             1.创建一个可观察的物体，以解决左右之间的歧义。
                2.让两个观测对象都发送数据。
                amb（_ :)运算符订阅左右可观察对象。 它等待它们中的任何一个发出一个元素，然后从另一个元素退订。 此后，它仅中继来自第一个活动可观察对象的元素。 它确实的确从歧义一词中得了名：起初，您不知道感兴趣的顺序，只想决定何时触发。
                该运算符经常被忽略。 它具有一些精选的实际应用程序，例如连接到冗余服务器并坚持首先响应的服务器
             */
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        // 1
        let observable = left.amb(right)
            _ = observable.subscribe(onNext: { value in
        print(value)
         })
        // 2
        left.onNext("Lisbon")
        right.onNext("Copenhagen")
        left.onNext("London")
        left.onNext("Madrid")
        right.onNext("Vienna")
        left.onCompleted()
        right.onCompleted()
        }
        
        example(of: "switchLatest") {
            // 1
            let one = PublishSubject<String>()
            let two = PublishSubject<String>()
            let three = PublishSubject<String>()
            let source = PublishSubject<Observable<String>>()
                // 2
            let observable = source.switchLatest()
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
                // 3
                 source.onNext(one)
                 one.onNext("Some text from sequence one")
                 two.onNext("Some text from sequence two")
                 source.onNext(two)
                 two.onNext("More text from sequence two")
                 one.onNext("and also from sequence one")
                source.onNext(three)
                two.onNext("Why don't you see me?")
                one.onNext("I'm alone, help me")
                three.onNext("Hey it's three. I win.")
                source.onNext(one)
                one.onNext("Nope. It's me, one!")
                disposable.dispose()
        }
        
        example(of: "reduce") {
            //这与您对Swift集合所做的非常相似，但是具有可观察的序列。 上面的代码使用快捷方式（使用+运算符）来累积值。 这本身不是很容易解释。 要了解其工作原理，请使用以下代码替换上面可观察到的创建
        let source = Observable.of(1, 3, 5, 7, 9)
        // 1
        //let observable = source.reduce(0, accumulator: +)
        //操作员“累积”汇总值。 它以您提供的初始值开头（在此示例中，您以0开头）。 每当源可观察对象发出RxSwift-使用Swift进行反应式编程第9章：组合
        //reduce（_：_ :)调用您的闭包以产生新的摘要。 当源可观察值完成时，reduce（_：_ :)发出摘要值，然后完成
            let observable = source.reduce(0) { summary, newValue in
            return summary + newValue
             }
        _ = observable.subscribe(onNext: { value in
        print(value)
         })
        //注意：reduce（_：_ :)仅在可观察源完成时才产生其摘要（累加）值。 将此运算符应用于从未完成的序列不会发出任何结果。 这是造成混乱和隐患的常见原因。
        }
        
        example(of: "scan") {
        let source = Observable.of(1, 3, 5, 7, 9)
        let observable = source.scan(0, accumulator: +)
        _ = observable.subscribe(onNext: { value in
        print(value)
         })
        }
     
        //第十一章
        
        let elementsPerSecond = 1
        let maxElements = 58
        let replayElements = 1
        let replayDelay : TimeInterval = 3
        
        let sourceObservable = Observable<Int>
            .create{
              observer in
                var value = 1
                let timer = DispatchSource.timer(interval: 1.0/Double(elementsPerSecond), queue: .main) {
                    
                    if value <= maxElements {
                        observer.onNext(value)
                        value += 1
                    }
                    
                }
                return Disposables.create {
                    timer.suspend()
                }
            }
            //.replay(replayElements)
            .replayAll()
        /*
         此运算符创建一个新序列，该序列记录可观察到的源发出的最后一个replayedElements。 每次有新观察者订阅时，它都会立即接收缓冲的元素（如果有的话），并像普通观察者一样继续接收任何新元素。
            若要可视化replay（_ :)的实际效果，请创建几个TimelineView视图。
            此类在操场页面的底部定义，并依赖于操场“源”组中的TimelineViewBase类。 它提供了可观察对象发出的事件的实时可视化。 在您刚刚编写的代码下方附加
         */
        
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
            UILabel.make("replay"),
            UILabel.make("Emit \(elementsPerSecond) per second"),
            sourceTimeline,
            UILabel.make("Replay \(replayElements) after \(replayDelay) sec"),
            replayedTimeline
        ])
        //准备立即订户并在最上面的时间轴中显示收到的内容：
        _ = sourceObservable.subscribe(sourceTimeline)
        //TimelineView类实现RxSwift的ObserverType协议。 因此，您可以订阅一个可观察的序列，它将接收该序列的事件。 每次发生新事件（发出元素，完成序列或出错）时，TimelineView都会在时间轴上显示该事件。 发射的元素以绿色显示，完成以黑色显示，错误以红色显示。
        //这将在另一个时间轴视图中显示第二个订阅接收的元素。
        //我保证，您很快就会看到时间轴视图！
        //由于replay（_ :)创建了一个可连接的可观察对象，因此您需要将其连接到其基础源以开始接收项目。 如果您忘记了这一点，订阅者将永远不会收到任何东西。
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay){
            
            _ = sourceObservable.subscribe(replayedTimeline)
        }
        /*
         
         注意：可连接的可观察对象是一类特殊的可观察对象。 无论订阅者有多少，他们都不会开始发出项目，除非您调用其connect（）方法。 尽管这超出了本章的范围，但请记住，一些运算符返回ConnectableObservable <E>，而不是Observable <E>。
            这些运算符是：replay（_ :) replayAll（）多播（_ :) publish（）本章介绍了重放运算符。 最后两个运算符是高级的，本书仅作简要介绍。 它们允许共享对可观察对象的单个订阅，而不管观察者的数量如何
         */
        //self.view.backgroundColor = UIColor .blue;
        _ = sourceObservable.connect()
        let hostView = setupHostView()
        hostView.addSubview(stack)
        self.view.addSubview(hostView)
       
        //既然您已经谈到了可重播序列，那么您可以看一个更高级的主题：受控缓冲。 首先，请看一下buffer（timeSpan：count：scheduler :)运算符。 切换到操场上称为缓冲的第二页。 与前面的示例一样，您将从一些常量开始：
        let bufferTimeSpan :RxTimeInterval = .seconds(4)
        let bufferMaxCount = 2
        //这些常量定义了您即将添加到代码中的缓冲区运算符的行为。 在此示例中，您将手动为主题提供值。 添加
        let sourceObservable1 = PublishSubject<String>()
        let sourceTimeline1 = TimelineView<String>.make()
        let bufferTimeline = TimelineView<Int>.make()
        //您将把短字符串（单个表情符号）推送到该可观察对象。 创建时间线可视化和堆栈以包含它们，就像之前一样
        let stack1 = UIStackView.makeVertical([
            UILabel.make("buffer"),
            UILabel.make("Emitted elements"),
            sourceTimeline1,
            UILabel.make("Buffered elements (at most\(bufferMaxCount) every \(bufferTimeSpan) seconds):"),
            bufferTimeline
        
        
        
        ])
        //订阅，以将事件填充到顶部时间轴中
        _ = sourceObservable1.subscribe(sourceTimeline1)
        /*
         •您希望从可观察的源中接收元素数组。
            •每个数组最多可以容纳bufferMaxCount元素。
            •如果在bufferTimeSpan到期之前收到了许多元素，则操作员将发出缓冲的元素并重置其计时器。
            •在最后一个发出组之后bufferTimeSpan的延迟中，buffer将发出一个数组。 如果在此时间段内未收到任何元素，则该数组为空。
            要激活您的时间轴视图，请设置主机视图：
         */
        sourceObservable1.buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
            .map(\.count)
            .subscribe(bufferTimeline)
        
        
        let hostView1 = setupHostView()
        hostView1.addSubview(stack1)
        self.view.addSubview(hostView1);
        /*
         即使在源上​​没有活动可观察到，您也可以在缓冲的时间轴上看到空缓冲区。 如果未观察到缓冲区的任何源，则buffer（_：scheduler :)运算符会定期发射空数组。
            0表示从源序列中发出了零个元素。
            您可以开始将原始可观察物与数据一起提供，并观察对缓冲可观察物的影响。 首先，尝试在五秒钟内推动三个元素。 附加
         */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
         sourceObservable1.onNext("🐱")
         sourceObservable1.onNext("🐱")
         sourceObservable1.onNext("🐱") }
        
    }
    public func example(of description: String, action: () -> Void)
    {
    print("\n--- Example of:", description, "---")
     action()
    }
    func printSomething<T: CustomStringConvertible>(label: String, event:
    Event<T>) {
     print(label, (event.element ?? event.error) ?? event)
    }

}

public extension DispatchSource {
    public class func timer(interval:Double,queue:DispatchQueue,handle:@escaping() -> Void) ->DispatchSourceTimer{
        
        let source = DispatchSource.makeTimerSource( queue: queue)
        source.setEventHandler(handler: handle)
        source.schedule(deadline: .now(),repeating: interval,leeway: .nanoseconds(0))
        source.resume()
        
        return source
        
    }
}

public struct TimelineEvent  {
  public enum EventType {
    case next(String)
    case completed(Bool)
    case error
  }
  public let date: Date
  public let event: EventType
  fileprivate var view: UIView? = nil
  
  public static func next(_ text: String) -> TimelineEvent {
    return TimelineEvent(.next(text))
  }
  public static func next(_ value: Int) -> TimelineEvent {
    return TimelineEvent(.next(String(value)))
  }
  public static func completed(_ keepRunning: Bool = false) -> TimelineEvent {
    return TimelineEvent(.completed(keepRunning))
  }
  public static func error() -> TimelineEvent {
    return TimelineEvent(.error)
  }
  
  var text: String {
    switch self.event {
    case .next(let s):
      return s
    case .completed(_):
      return "C"
    case .error:
      return "X"
    }
  }
  
  init(_ event: EventType) {
    // lose some precision to show nearly-simultaneous items at same position
    let ti = round(Date().timeIntervalSinceReferenceDate * 10) / 10
    date = Date(timeIntervalSinceReferenceDate: ti)
    self.event = event
  }
}

let BOX_WIDTH: CGFloat = 40

open class TimelineViewBase : UIView {
  var timeSpan: Double = 10.0
  var events: [TimelineEvent] = []
  var displayLink: CADisplayLink?
  
  public convenience init(width: CGFloat, height: CGFloat) {
    self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not supported here")
  }

  public func setup() {
    self.backgroundColor = .white
    self.widthAnchor.constraint(equalToConstant: CGFloat(frame.width)).isActive = true
    self.heightAnchor.constraint(equalToConstant: CGFloat(frame.height)).isActive = true
  }
  
  public func add(_ event: TimelineEvent) {
    let label = UILabel()
    label.isHidden = true
    label.textAlignment = .center
    label.text = event.text
    
    switch event.event {
    case .next(_):
      label.backgroundColor = .green

    case .completed(let keepRunning):
      label.backgroundColor = .black
      label.textColor = .white
      if !keepRunning {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.detachDisplayLink() }
      }
    
    case .error:
      label.backgroundColor = .red
      label.textColor = .white
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.detachDisplayLink() }
    }
    
    label.layer.borderColor = UIColor.lightGray.cgColor
    label.layer.borderWidth = 1.0
    label.sizeToFit()
    
    var r = label.frame
    r.size.width = BOX_WIDTH
    label.frame = r
    
    var newEvent = event
    newEvent.view = label
    events.append(newEvent)
    addSubview(label)
  }
  
  func detachDisplayLink() {
    displayLink?.remove(from: RunLoop.main, forMode: .common)
    displayLink = nil
  }
  
  override open func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    self.backgroundColor = .white
    if newSuperview == nil {
      detachDisplayLink()
    } else {
      displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
      displayLink?.add(to: RunLoop.main, forMode: .common)
    }
  }
  
  override open func draw(_ rect: CGRect) {
    UIColor.lightGray.set()
    UIRectFrame(CGRect(x: 0, y: rect.height/2, width: rect.width, height: 1))
    super.draw(rect)
  }
  
  @objc func update(_ sender: CADisplayLink) {
    let now = Date()
    let start = now.addingTimeInterval(-11)
    let width = frame.width
    let increment = (width - BOX_WIDTH) / 10.0
    events
      .filter { $0.date < start }
      .forEach { $0.view?.removeFromSuperview() }
    var eventsAt = [Int:Int]()
    events = events.filter { $0.date >= start }
    events.forEach { box in
      if let view = box.view {
        var r = view.frame
        let interval = CGFloat(box.date.timeIntervalSince(now))
        let origin = Int(width - BOX_WIDTH + interval * increment)
        let count = (eventsAt[origin] ?? 0) + 1
        eventsAt[origin] = count
        r.origin.x = CGFloat(origin)
        r.origin.y = (frame.height - r.height) / 2 + CGFloat(12 * (count - 1))
        view.frame = r
        view.isHidden = false
        //print("[\(eventsAt[origin]!)]: \"\(box.text)\" x=\(origin) y=\(r.origin.y)")
      }
    }
  }
}

class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    view.setup()
    return view
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.next(String(describing: value)))
    case .completed:
      add(.completed())
    case .error(_):
      add(.error())
    }
  }
}

extension UIStackView {
  public class func makeVertical(_ views: [UIView]) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: views)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.distribution = .fill
    stack.axis = .vertical
    stack.spacing = 15
    return stack
  }
  
  public func insert(_ view: UIView, at index: Int) {
    insertArrangedSubview(view, at: index)
  }
  
  public func keep(atMost: Int) {
    while arrangedSubviews.count > atMost {
      let view = arrangedSubviews.last!
      removeArrangedSubview(view)
      view.removeFromSuperview()
    }
  }
}

extension UILabel {
  public class func make(_ title: String) -> UILabel {
    let label = UILabel()
    label.text = title
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }
  
  public class func makeTitle(_ title: String) -> UILabel {
    let label = make(title)
    label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize * 2.0)
    label.textAlignment = .center
    return label
  }
}
public func setupHostView() -> UIView {
  
  let hostView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 640))
  hostView.backgroundColor = .white

  
  
  return hostView
}

