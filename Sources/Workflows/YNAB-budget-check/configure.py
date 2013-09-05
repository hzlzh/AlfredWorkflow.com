import alp

path = alp.args()[0]
s = alp.Settings()
s.set(**{"budget_path": path})
print "YNAB budget path set!"