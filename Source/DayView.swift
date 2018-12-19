import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDelegate: AnyObject {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidLongPressTimelineAtHour(_ hour: Int)
  func dayView(dayView: AbstractDayView, willMoveTo date: Date)
  func dayView(dayView: AbstractDayView, didMoveTo  date: Date)
}

public class AbstractDayView: UIView {

  public weak var delegate: DayViewDelegate?

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      setNeedsLayout()
    }
  }

  public var timelineScrollOffset: CGPoint {
    return timelinePagerView.timelineScrollOffset
  }

  static let headerVisibleHeight: CGFloat = 88
  var headerHeight: CGFloat = headerVisibleHeight

  open var autoScrollToFirstEvent: Bool {
    get {
      return timelinePagerView.autoScrollToFirstEvent
    }
    set (value) {
      timelinePagerView.autoScrollToFirstEvent = value
    }
  }

  let dayHeaderView = DayHeaderView()
  let timelinePagerView = TimelinePagerView()
  public var cornerView: UIView {
    get {
      return dayHeaderView.cornerView
    }
    set(value) {
      dayHeaderView.cornerView = value
    }
  }

  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  var style = CalendarStyle()

  public init(state: DayViewState) {
    super.init(frame: .zero)
    self.state = state
    configure()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    addSubview(timelinePagerView)
    addSubview(dayHeaderView)
    timelinePagerView.delegate = self

    if state == nil {
      state = DayViewState()
    }
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle.copy() as! CalendarStyle
    dayHeaderView.updateStyle(style.header)
    timelinePagerView.updateStyle(style.timeline)
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    timelinePagerView.timelinePanGestureRequire(toFail: gesture)
  }

  public func scrollTo(hour24: Float) {
    timelinePagerView.scrollTo(hour24: hour24)
  }

  public func scrollToFirstEventIfNeeded() {
    timelinePagerView.scrollToFirstEventIfNeeded()
  }

  public func reloadData() {
    timelinePagerView.reloadData()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePagerView.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    dayHeaderView.transitionToHorizontalSizeClass(sizeClass)
    updateStyle(style)
  }
}

extension AbstractDayView: EventViewDelegate {
  public func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
}

extension AbstractDayView: TimelinePagerViewDelegate {
  public func timelinePagerDidSelectEventView(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
    delegate?.dayViewDidLongPressEventView(eventView)
  }
  public func timelinePagerDidLongPressTimelineAtHour(_ hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
  public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
    delegate?.dayView(dayView: self, willMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
    delegate?.dayView(dayView: self, didMoveTo: date)
  }
}

extension AbstractDayView: TimelineViewDelegate {
  public func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
}

public class DayView: AbstractDayView {
  public weak  var  dataSource:  EventDataSource? {
    didSet {
      timelinePagerView.trigger =  { [weak  self] in
        guard let me = self, let dataSource  = me.dataSource  else { return }
        me.timelinePagerView.processEvents(dataSource.eventsForDate($0.dateOnly()), timeline: $1)
      }
    }
  }
}

public class AsynchronousDayView: AbstractDayView {
  public struct EventDate  {
    public let value: Date
  }

  public var trigger:  ((EventDate) ->  Void)? {
    didSet {
      timelinePagerView.trigger =  { [weak  self] (date, timeline) in
        guard let me = self, let trigger = me.trigger else { return  }
        trigger(EventDate(value: date))
      }
    }
  }

  public func  receive(events:  [EventDescriptor], for date: EventDate)  {
    timelinePagerView.receive(events: events, for: date.value)
  }
}
