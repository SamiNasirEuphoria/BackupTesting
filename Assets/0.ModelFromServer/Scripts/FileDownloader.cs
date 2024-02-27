using UnityEngine;
using UnityEngine.Networking;
using System.IO;
using System.Collections;

public class FileDownloader : MonoBehaviour
{
    // URL of the file on Dropbox
    public string fileURL;

    // Path where you want to save the downloaded file in Unity project's assets folder
    public string savePath = "/Users/mac/Desktop/Projects/ParticleEffect/Assets/Download";

    public void DownloadFile()
    {
        StartCoroutine(DownloadAndSaveFile());
    }

    IEnumerator DownloadAndSaveFile()
    {
        // Send a web request to download the file
        using (UnityWebRequest webRequest = UnityWebRequest.Get(fileURL))
        {
            // Wait for the download to complete
            yield return webRequest.SendWebRequest();

            // Check for errors
            if (webRequest.result == UnityWebRequest.Result.ConnectionError ||
                webRequest.result == UnityWebRequest.Result.ProtocolError)
            {
                Debug.LogError("Error downloading file: " + webRequest.error);
            }
            else
            {
                // Save the downloaded file to the specified path
                File.WriteAllBytes(savePath, webRequest.downloadHandler.data);
                Debug.Log("File downloaded and saved successfully to: " + savePath);
            }
        }
    }
}

