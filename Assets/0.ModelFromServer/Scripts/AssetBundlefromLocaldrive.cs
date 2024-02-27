using UnityEngine;
using System.IO;
using System.Collections;

public class AssetBundlefromLocaldrive : MonoBehaviour
{
    public string assetBundleName;
    void Start()
    {
        //StartCoroutine(LoadAssetBundle());
        //StartCoroutine(ResourceLoader());
        StartCoroutine(AssetBundles());
        //Simple();
    }
    IEnumerator LoadAssetBundle()
    {
        string path = Path.Combine(Application.streamingAssetsPath, assetBundleName); // Path to your AssetBundle file
        var bundleRequest = AssetBundle.LoadFromFileAsync(path);
        yield return bundleRequest;

        AssetBundle bundle = bundleRequest.assetBundle;
        if (bundle == null)
        {
            Debug.Log("Failed to load AssetBundle!");
            yield break;
        }

        GameObject prefab = bundle.LoadAsset<GameObject>("player");
        Instantiate(prefab);

        // Use the loaded AssetBundle here...

        bundle.Unload(false); // Unload the AssetBundle when you're done using its assets
    }
    IEnumerator LoadFromMemoryAsync(string path)
    {
        AssetBundleCreateRequest createRequest = AssetBundle.LoadFromMemoryAsync(File.ReadAllBytes(path));
        yield return createRequest;
        AssetBundle bundle = createRequest.assetBundle;
        var prefab = bundle.LoadAsset<GameObject>("MyObject")as GameObject;
        Instantiate(prefab);
    }
    //loading any file from computer memory
    IEnumerator ResourceLoader()
    {
        yield return new WaitForEndOfFrame();
        var temp = Resources.Load("Apple_FBX") as GameObject;
        Instantiate(temp);
    }
    IEnumerator AssetBundles()
    {
        yield return new WaitForEndOfFrame();

        AssetBundle myLoadedAssetBundle = AssetBundle.LoadFromFile("Assets/Resources/arisa");

        if (myLoadedAssetBundle == null)
        {
            Debug.Log("Failed to load AssetBundle!");
        }
        GameObject prefab = myLoadedAssetBundle.LoadAsset<GameObject>("arisa");
        Instantiate(prefab);
    }
    void Simple()
    {
        GameObject loadedObject;
       Debug.Log(AssetBundle.GetAllLoadedAssetBundles());
        // loadedObject = Instantiate(AssetBundle.GetAllLoadedAssetBundles());
    }
}
