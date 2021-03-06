import sys
sys.path.insert(1, "../../")
import h2o, tests

def frame_as_list(ip,port):
    
    

    iris = h2o.import_file(path=h2o.locate("smalldata/iris/iris_wheader.csv"))
    prostate = h2o.import_file(path=h2o.locate("smalldata/prostate/prostate.csv.zip"))
    airlines = h2o.import_file(path=h2o.locate("smalldata/airlines/allyears2k.zip"))

    res1 = h2o.as_list(iris, use_pandas=False)
    assert abs(float(res1[9][0]) - 4.4) < 1e-10 and abs(float(res1[9][1]) - 2.9) < 1e-10 and \
           abs(float(res1[9][2]) - 1.4) < 1e-10, "incorrect values"

    res2 = h2o.as_list(prostate, use_pandas=False)
    assert abs(float(res2[7][0]) - 7) < 1e-10 and abs(float(res2[7][1]) - 0) < 1e-10 and \
           abs(float(res2[7][2]) - 68) < 1e-10, "incorrect values"

    res3 = h2o.as_list(airlines, use_pandas=False)
    assert abs(float(res3[4][0]) - 1987) < 1e-10 and abs(float(res3[4][1]) - 10) < 1e-10 and \
           abs(float(res3[4][2]) - 18) < 1e-10, "incorrect values"

if __name__ == "__main__":
    tests.run_test(sys.argv, frame_as_list)
