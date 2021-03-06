package water.api;

import water.Iced;

/**
 * Model export REST end-point.
 */
public class ModelExportV3 extends RequestSchema<Iced, ModelExportV3> {

  /** Model to export. */
  @API(help="Name of Model of interest", json=false)
  public KeyV3.ModelKeyV3 model_id;

  /** Destination directory to save exported model. */
  @API(help="Destination directory (hdfs, s3, local)")
  public String dir;

  /** Destination directory to save exported model. */
  @API(help="Overwrite destination directory in case it exists or throw exception if set to false.")
  public boolean force = true;
}
