# CaffeOnSpark

Light Docker image for Yahoo CaffeOnSpark.
Built from mesosphere/spark:1.0.1-1.6.2, includes Hadoop, OpenBlas, CaffeOnSpark (distributed version of Caffe).
Caffe source code and included data are deleted after compilation for image size management.
Runs on Spark cluster.

Spark job submission example :

spark-submit --master ${MASTER_URL} \
--files ${PATH/TO/SOLVER.prototxt}, ${PATH/TO/NET.prototxt} \
--conf spark.cores.max=${TOTAL_CORES} \
--conf spark.task.cpus=${CORES_PER_WORKER} \
--conf spark.driver.extraLibraryPath="${LD_LIBRARY_PATH}" \
--conf spark.executorEnv.LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" \
--class com.yahoo.ml.caffe.CaffeOnSpark \
${CAFFE_ON_SPARK}/caffe-grid/target/caffe-grid-0.1-SNAPSHOT-jar-with-dependencies.jar \
-train \
-features accuracy,loss -label label \
-conf ${SOLVER.prototxt} \
-clusterSize ${SPARK_WORKER_INSTANCES} \
-devices 1 \
-connection ethernet \
-model file:${PATH/TO/MODEL.model} \
-output file:${PATH/TO/FEATURES_RESULTS}
Light Docker image for Yahoo CaffeOnSpark.
Built from mesosphere/spark:1.0.1-1.6.2, includes Hadoop, OpenBlas, CaffeOnSpark (distributed version of Caffe).
Caffe source code and included data are deleted after compilation for image size management.
Runs on Spark cluster.

Spark job submission example :

spark-submit --master ${MASTER_URL} \
--files ${PATH/TO/SOLVER.prototxt}, ${PATH/TO/NET.prototxt} \
--conf spark.cores.max=${TOTAL_CORES} \
--conf spark.task.cpus=${CORES_PER_WORKER} \
--conf spark.driver.extraLibraryPath="${LD_LIBRARY_PATH}" \
--conf spark.executorEnv.LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" \
--class com.yahoo.ml.caffe.CaffeOnSpark \
${CAFFE_ON_SPARK}/caffe-grid/target/caffe-grid-0.1-SNAPSHOT-jar-with-dependencies.jar \
-train \
-features accuracy,loss -label label \
-conf ${SOLVER.prototxt} \
-clusterSize ${SPARK_WORKER_INSTANCES} \
-devices 1 \
-connection ethernet \
-model file:${PATH/TO/MODEL.model} \
-output file:${PATH/TO/FEATURES_RESULTS}
