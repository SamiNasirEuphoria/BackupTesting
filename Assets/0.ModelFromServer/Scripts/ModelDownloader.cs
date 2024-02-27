
using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using TriLibCore;
using System.Collections.Generic;
using TriLibCore.SFB;

public class ModelDownloader : MonoBehaviour
{
    public string url; private IList _items;
    public string AssetName;
    private void Start()
    {
        StartCoroutine("DownloadZipFile");
        //CheckAllFilesInFolder();
    }
    void CheckAllFilesInFolder()
    {
        string[] files = Directory.GetFiles(Application.persistentDataPath);

        foreach (string filePath in files)
        {
            if (Path.GetFileName(filePath) == AssetName+".zip")
            {
                Debug.Log("Found " + Path.GetFileName(filePath) + " in persistent data path.");
                LoadModel();
            }
               
                //LoadModel();
            //}
          //  else
            //{
                //using (UnityWebRequest www = UnityWebRequest.Get(url))
                //{
                //    print("Start downloading zip file");
                //    yield return www.Send();
                //    if (www.isNetworkError || www.isHttpError)
                //    {
                //        Debug.Log(www.error);
                //    }
                //    else
                //    {
                //        string path = Path.Combine("/Assets/Download");
                //        string savePath = string.Format("{0}/{1}.zip", Application.persistentDataPath, AssetName);
                //        string savepath = Path.Combine(Application.persistentDataPath, AssetName);
                //        File.WriteAllBytes(savePath, www.downloadHandler.data);
                //        print("Target Zip file downloaded");
                //        //LoadModel();
                //    }
                //}
            //}
        }

    }

    private IEnumerator DownloadZipFile()
    {
        CheckAllFilesInFolder();
        Debug.Log(Application.persistentDataPath);
        if (File.Exists(Application.persistentDataPath + "/GreenGirl.zip"))
        {
            print("Target Zip file exists");
            //LoadModel();
        }

        if (!File.Exists(Application.persistentDataPath + "/GreenGirl.zip"))
        {
            print("Target Zip file doesn't exists");

            using (UnityWebRequest www = UnityWebRequest.Get(url))
            {
                print("Start downloading zip file");
                yield return www.Send();
                if (www.isNetworkError || www.isHttpError)
                {
                    Debug.Log(www.error);
                }
                else
                {
                    string path = Path.Combine("/Assets/Download");
                    string savePath = string.Format("{0}/{1}.zip", Application.persistentDataPath, "/GreenGirl");
                    string savepath = Path.Combine(Application.persistentDataPath, AssetName);
                    File.WriteAllBytes(savePath, www.downloadHandler.data);
                    print("Target Zip file downloaded");
                    //LoadModel();
                }
            }
        }
    }


    void LoadModel()
    {
        print("Start loading zip file");
        var hasFiles = _items != null && _items.Count > 0; //&& _items[0].hasData;
        var assetLoaderOptions = AssetLoader.CreateDefaultLoaderOptions();
        string path = Path.Combine(AssetName + ".zip");
        AssetLoaderZip.LoadModelFromZipFile(Application.persistentDataPath + "/GreenGirl.zip", OnLoad, OnMaterialsLoad, OnProgress, OnError, null, assetLoaderOptions, _items, null);
        //AssetLoader.LoadModelFromFile(Application.persistentDataPath+path);
    }

    private void OnError(IContextualizedError obj)
    {
        Debug.LogError($"An error occurred while loading your Model: {obj.GetInnerException()}");
    }

    private void OnProgress(AssetLoaderContext assetLoaderContext, float progress)
    {
        Debug.Log($"Loading Model. Progress: {progress:P}");
    }

    private void OnMaterialsLoad(AssetLoaderContext assetLoaderContext)
    {
        Debug.Log("Materials loaded. Model fully loaded.");
    }
    private void OnLoad(AssetLoaderContext assetLoaderContext)
    {
        Debug.Log("Model loaded. Loading materials.");
    }
}