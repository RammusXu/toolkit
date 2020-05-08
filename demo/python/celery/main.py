from tasks import add

r = add.delay(2, 2)
r = add.delay(3, 3)
print(r.ready())
print(r.result)
print(r.get())