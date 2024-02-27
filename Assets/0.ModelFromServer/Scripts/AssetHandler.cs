using System.Collections;
using UnityEngine;
using UnityEngine.Networking;
using System.IO;

public class AssetHandler : MonoBehaviour
{
    public string url;
    public string prefabName;
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(SendWebRequest());
    }
    IEnumerator SendWebRequest()
    {
        UnityWebRequest request = UnityWebRequestAssetBundle.GetAssetBundle(url);
        yield return request.SendWebRequest();
        Debug.Log("In Coroutine");
        if (request.result != UnityWebRequest.Result.Success)
        {
            yield break;
            Debug.LogError("There is an error in URL");

        }
        else
        {
            Debug.Log("WebRequest Success");
            AssetBundle bundle = DownloadHandlerAssetBundle.GetContent(request);

            GameObject prefab = bundle.LoadAsset<GameObject>(prefabName);
            string savePath = "/Users/mac/Desktop/Projects/ParticleEffect/Assets/Download";
            string savePath2 = Application.persistentDataPath + "/" + prefabName + ".assetbundle";
            string savepath = Path.Combine(Application.persistentDataPath, "Assets/Download");
            Debug.Log(Application.persistentDataPath);
            //byte[] bytes = request.downloadHandler.data;

            File.WriteAllBytes(Application.persistentDataPath, request.downloadHandler.data);
            Instantiate(prefab);
            yield return null;
            bundle.Unload(false);
        }
    }
}
