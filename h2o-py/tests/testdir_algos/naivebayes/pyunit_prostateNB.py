import sys
sys.path.insert(1, "../../../")
import h2o, tests

def nb_prostate(ip, port):
    

    print "Importing prostate.csv data..."
    prostate = h2o.upload_file(h2o.locate("smalldata/logreg/prostate.csv"))

    print "Converting CAPSULE, RACE, DCAPS, and DPROS to categorical"
    prostate['CAPSULE'] = prostate['CAPSULE'].asfactor()
    prostate['RACE'] = prostate['CAPSULE'].asfactor()
    prostate['DCAPS'] = prostate['DCAPS'].asfactor()
    prostate['DPROS'] = prostate['DPROS'].asfactor()

    print "Compare with Naive Bayes when x = 3:9, y = 2"
    prostate_nb = h2o.naive_bayes(x=prostate[2:9], y=prostate[1], laplace = 0)
    prostate_nb.show()

    print "Predict on training data"
    prostate_pred = prostate_nb.predict(prostate)
    prostate_pred.head()

if __name__ == "__main__":
    tests.run_test(sys.argv, nb_prostate)
