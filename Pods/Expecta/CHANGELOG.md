v0.2.0
======

* New matcher syntax [TrahDivad]
* Extracted matcher functionality to its own class and protocol [lukeredpath]
* Dynamic predicate matchers [lukeredpath]
* raise/raiseAny matcher
* haveCountOf/beEmpty matcher [TrahDivad]
* contain matcher now handles any object that conforms to NSFastEnumeration [TrahDivad]
* Fixed false negative bug with async matchers [TrahDivad]

v0.1.3
======

* Fixed toBeSubClass matcher no longer working in iOS4
* Fixed minor bugs

v0.1.2
======

* Fixed toBeInstanceOf matcher not working with objects stored in an variable of type id
* Improved the formatting of NSSet objects in output

v0.1.1
======

* Improved the formatting of NSDictionary and NSArray objects in the output
* Improved handling of Class objects

v0.1.0
======

* First Cocoapods release
* toBeLessThan/toBeLessThanOrEqualTo/toBeGreaterThan/toBeGreaterThanOrEqualTo matchers [akitchen]
* toBeInTheRangeOf matcher [joncooper]
* Line-number highlighting in XCode [twobitlabs]
* Supports float/double tuples (e.g. CGPoint, CGRect) [kseebaldt]

