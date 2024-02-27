using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.Events;
using UnityEngine.UI;
using TriLibCore;

public class ModelLoader : MonoBehaviour
{
    private string url; private IList _items;
    private string sample;
    private static ModelLoader instance;
    public float downloadLoading;
    public static ModelLoader Instance
    {
        get
        {
            return instance;
        }
    }
    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }else if(instance!= this)
        {
            Destroy(this.gameObject);
        }
    }
    private void Start()
    {
        //StartCoroutine(DownloadZipFile(sample, url));
    }
    public bool CheckForFileInFolder(string fileName)
    {
        if (File.Exists(Application.persistentDataPath + "/" + fileName + ".zip"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public IEnumerator LoadZipFile(string fileName, GameObject childObject)
    {
        yield return null;
        LoadModel(fileName, childObject);
    }
    public IEnumerator _DownloadZipFile(string fileName, string URL, Text loading, Image myImage, GameObject childObject, Button button)
    {
        using (UnityWebRequest www = UnityWebRequest.Get(URL))
        {
            print("Start downloading zip file");
            yield return www.Send();
            if (www.isNetworkError || www.isHttpError)
            {
                Debug.Log(www.error);
            }
            else
            {
                string savePath = string.Format("{0}/{1}.zip", Application.persistentDataPath, fileName);
                File.WriteAllBytes(savePath, www.downloadHandler.data);
                print("Target Zip file downloaded");
                LoadingModel(fileName, myImage,loading , childObject, button);
            }
        }
    }
    public IEnumerator DownloadZipFile(string fileName, string URL)
    {
        Debug.Log("Coroutine get called");
        if (File.Exists(Application.persistentDataPath +"/"+fileName+".zip"))
        {
            print("Target Zip file exists");
           // LoadModel(fileName);
        }

        if (!File.Exists(Application.persistentDataPath + "/"+fileName+".zip"))
        {
            print("Target Zip file doesn't exists");

            using (UnityWebRequest www = UnityWebRequest.Get(URL))
            {
                print("Start downloading zip file");
                yield return www.Send();
                if (www.isNetworkError || www.isHttpError)
                {
                    Debug.Log(www.error);
                }
                else
                {
                    string savePath = string.Format("{0}/{1}.zip", Application.persistentDataPath, fileName);
                    File.WriteAllBytes(savePath, www.downloadHandler.data);
                    print("Target Zip file downloaded");
                    //LoadModel(fileName);
                }
            }
        }
    }


    void LoadModel(string _fileName, GameObject chidlobject)
    {
        string path = "/"+_fileName+".zip";
        print("Start loading zip file");
        var hasFiles = _items != null && _items.Count > 0; //&& _items[0].HasData;
        var assetLoaderOptions = AssetLoader.CreateDefaultLoaderOptions();
        var parentObject = chidlobject;
        AssetLoaderZip.LoadModelFromZipFile(Application.persistentDataPath +path, OnLoad, OnMaterialsLoad, OnProgress, OnError, parentObject, assetLoaderOptions, _items, null);
    }
    void LoadingModel(string _fileName, Image image, Text _loading, GameObject childObject, Button button)
    {
        string path = "/" + _fileName + ".zip";
        print("Start loading zip file");
        var hasFiles = _items != null && _items.Count > 0; //&& _items[0].HasData;
        var assetLoaderOptions = AssetLoader.CreateDefaultLoaderOptions();
        var parentObject = childObject;
        AssetLoaderZip.LoadModelFromZipFile(Application.persistentDataPath + path, OnLoad, OnMaterialsLoad, OnProgress, OnError, parentObject, assetLoaderOptions, _items, null);
        image.sprite = null;
        button.interactable = true;
        _loading.text = "successful";
    }
    private void OnError(IContextualizedError obj)
    {
        Debug.LogError($"An error occurred while loading your Model: {obj.GetInnerException()}");
    }

    private void OnProgress(AssetLoaderContext assetLoaderContext, float progress)
    {
        Debug.Log($"Loading Model. Progress: {progress:P}");
        downloadLoading = progress;
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
