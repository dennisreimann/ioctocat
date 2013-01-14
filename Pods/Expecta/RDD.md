# Expecta RDD

## To Be Implemented

### BOOL

>`expect(x).beYes();` passes if x is a BOOL value of YES
>
>`expect(x).beNo();` passes if x is a BOOL value of NO

### Class

>`expect(x).toConformToProtocol(y);` passes if class or object x conforms to protocol y

### Object

>`expect(x).toConformToProtocol(y);` passes if class or object x conforms to protocol y
>
>`expect(x).toRespondToSelector(y);` passes if class or object x responds to selector y

### Number

>`expect(x).beLessThan(y);` passes if x is less than y
>
>`expect(x).beLessThanOrEqualTo(y);` passes if x is less than or equal to y
>
>`expect(x).beGreaterThan(y);` passes if x is greater than y
>
>`expect(x).beGreaterThanOrEqualTo(y);` passes if x is greater than or equal to y
>
>`expect(x).beCloseTo(y, z);` passes if x is equal to y to a precision of z decimal places
>
>`expect(x).beInTheRangeOf(y, z);` passes if x is in the range of [y, z]

### Exceptions

>`expect(^{ expr; }).toThrow(e);` passes if expr throws an exception e when executed
>
>`expect(^{ expr; }).toChange(x.hello, z);` passes if expr changes x.hello by amount z

### String

>`expect(x).toMatch(y);` compares x to a regex pattern y and passes if they match

### Collection

>`expect(x).beEmpty();` passes if x is empty
>
>`expect(x).toHaveCountOf(y);` passes if x contains y number of objects
>
>`expect(x).toHaveCountOfAtLeast(y);` passes if x contains at least y number of objects
>
>`expect(x).toHaveCountOfAtMost(y);` passes if x contains at most y number of objects
