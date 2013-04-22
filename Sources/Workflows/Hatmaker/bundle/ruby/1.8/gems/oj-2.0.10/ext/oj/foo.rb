
def foo()
  [1, [true, false]].each { |x| yield x }
end

foo() { |x| puts x }
