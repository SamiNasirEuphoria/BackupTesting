using System;
using UnityEngine;
using UnityEditor;

public class AssetBundle
{
   [MenuItem("Assets/Create Asset Bundles")]
   public static void BuildAllAssetBundle()
    {
        string projectPath = Application.dataPath + "/../AssetBundles";
        try
        {
            BuildPipeline.BuildAssetBundles(projectPath,BuildAssetBundleOptions.None,EditorUserBuildSettings.activeBuildTarget);

        }catch(Exception e)
        {
            Debug.LogError("Error is coming" + e);
        }
    }
}
