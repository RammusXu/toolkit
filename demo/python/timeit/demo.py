from timeit import timeit

def demo():
    print("hi")

print(timeit('demo()','from __main__ import demo',number=1))
