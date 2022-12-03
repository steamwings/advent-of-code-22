# Selection sort but returns new length of sorted, dedup'd array
# Assumes high(int) and low(int) are NOT valid input values
# This is of questionable value but it seems to be working
proc dedup_selection_sort*[T](a: var openArray[T]): int =
  var d = len(a) # Deduplicated array length
  var minVal = high(T) # Index of minimum for the inner loop
  var lastVal = low(T)

  for i in 0 ..< d:
    if i == d: break
    if a[i] == lastVal:
      while a[d-1] <= a[i]:
        if d == i: return d
        dec(d)
      a[i] = a[d-1]
      dec(d)
    var nextMin = i;
    for j in i ..< d:
      if a[j] > lastVal and a[j] < minVal:
        nextMin = j
        minVal = a[nextMin]
    if minVal == high(T): return i
    if nextMin != i:
      swap(a[i], a[nextMin])
    lastVal = a[i]
    minVal = high(T)
  return d