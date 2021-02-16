//
//  ViewController.swift
//  RxSwiftProtices
//
//  Created by liuningbo on 2021/2/15.
//

import UIKit
import RxSwift
import RxRelay
enum MyError: Error {
case anError
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

