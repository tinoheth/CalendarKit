import UIKit
import DateToolsSwift

open class AbstractDayViewController: UIViewController, DayViewDelegate {

  public private(set) lazy var dayView: AbstractDayView = loadDayView()

  func loadDayView() -> AbstractDayView {
    return DayView()
  }

  open override func loadView() {
    self.view = dayView
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    edgesForExtendedLayout = []
    view.tintColor = UIColor.red
    dayView.delegate = self
    dayView.reloadData()

    let sizeClass = traitCollection.horizontalSizeClass
    configureDayViewLayoutForHorizontalSizeClass(sizeClass)
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    dayView.scrollToFirstEventIfNeeded()
  }

  open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    configureDayViewLayoutForHorizontalSizeClass(newCollection.horizontalSizeClass)
  }

  func configureDayViewLayoutForHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    dayView.transitionToHorizontalSizeClass(sizeClass)
  }

  open func reloadData() {
    dayView.reloadData()
  }

  open func updateStyle(_ newStyle: CalendarStyle) {
    dayView.updateStyle(newStyle)
  }

  // MARK: DayViewDelegate

  open func dayViewDidSelectEventView(_ eventView: EventView) {
  }

  open func dayViewDidLongPressEventView(_ eventView: EventView) {
  }

  open func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
  }

  open func dayView(dayView: AbstractDayView, willMoveTo date: Date) {
  }

  open func dayView(dayView: AbstractDayView, didMoveTo date: Date) {
  }
}

open class DayViewController: AbstractDayViewController, EventDataSource {
  override func loadDayView() -> DayView {
    let result = DayView()
    result.dataSource = self
    return result
  }

  open func eventsForDate(_ date: Date) -> [EventDescriptor] {
    return [Event]()
  }
}

open class AsynchronousDayViewController: AbstractDayViewController {
  override func loadDayView() -> AbstractDayView {
    let result = AsynchronousDayView()
    result.trigger =  { [weak  self] (date) in
      guard let me = self else { return }
      me.trigger(date: date)
    }
    return result
  }

  open func trigger(date: AsynchronousDayView.EventDate){
    fatalError("This is an abstract class")
  }
}
