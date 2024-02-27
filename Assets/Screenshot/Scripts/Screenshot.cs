using System.Collections;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;
public enum filePath
{
	Downloads,
	UnityEditor,
	Desktop,
	Documents
}
public class Screenshot : MonoBehaviour
{
    public filePath filepath;
    public string screenshotName = "Screenshot_";
    [Header("* Album name to create in device")]
    public string folderName;
    [Space(5)]
    [Header("* SAVE screenshots to Gallery")]
    public bool saveToGallery;
    [Space(5)]
    [Header("* SHARE screenshots")]
    public bool share;
    [Space(5)]
    [Header("* WATERMARK on screenshots")]
    public bool watermark;
    [Space(5)]
    public string watermarkText;
    [Space(5)]
    [Header("* Pass All UI objects")]
    [Space(-15)]
    [Header("    you want to make 'invisible' in screenshot")]
    public GameObject[] UIObjects;
    [Space(5)]
    [Header("* Pass All GameObjects")]
    [Space(-15)]
    [Header("  you want to make 'Inactive' in screenshot")]
    public GameObject[] GameObjects;

    public Button capture;
	private Texture2D screenshotTexture;
	private bool takingScreenshot = false;
	private int numberOfCharsAllowed = 32;
	void Start()
    {
		capture.onClick.AddListener(_CaptureScreenshot);
    }
	// Update is called once per frame
	void Update()
	{
		//to auto-rename screenshot
		AutoPlaceholder();
#if UNITY_EDITOR
		ClickEditorScreen();
#endif
	}
	public void ClickEditorScreen()
    {
		if (Input.GetMouseButtonDown(0))
		{
			CaptureScreenshot();
		}
	}
	void DeactivateObjects(GameObject[] _Objects)
	{
		capture.gameObject.SetActive(false);
		foreach (GameObject obj in _Objects)
		{
			if (obj != null)
				obj.SetActive(false);
		}
	}

	void ReactivateObjects(GameObject[] _Objects)
	{
		capture.gameObject.SetActive(true);
		foreach (GameObject obj in _Objects)
		{
			if (obj != null)
				obj.SetActive(true);
		}
	}
	// this method is to rename screenshot automatically(only in editor mode)
	public void AutoPlaceholder()
    {
		if (string.IsNullOrEmpty(screenshotName))
		{
			screenshotName = "Screenshot_";
        }
        else
        {
			return;
        }
	}
	//filepath for screenshot only in editor mode
	public string FilePath()
    {
        if (filepath ==filePath.Downloads)
        {
			return "Downloads";
        }
		else if (filepath == filePath.UnityEditor)
        {
			return "UnityEditor";
        }
		else if(filepath == filePath.Desktop)
        {
			return "Desktop";
        }
		else if (filepath == filePath.Documents)
        {
			return "Documents";
        }
		return "Downloads";

	}
	//capture screen in editor mode
	public void CaptureScreenshot()
	{
		takingScreenshot = true;
		string screenshotName = this.screenshotName + System.DateTime.Now.ToString("yyyy-MM-dd-HHmmss-fff") + ".png";
		string downloadsFolderPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), FilePath());
		string filePath = Path.Combine(downloadsFolderPath, screenshotName);
		DeactivateObjects(GameObjects);
		DeactivateObjects(UIObjects);
		StartCoroutine(CaptureAndMoveScreenshot(screenshotName, filePath));
	}
	private IEnumerator CaptureAndMoveScreenshot(string screenshotName, string filePath)
	{
		
		ScreenCapture.CaptureScreenshot(screenshotName);
		
		// Wait for a short period to ensure the screenshot is saved
		yield return new WaitForSeconds(0.5f);
		takingScreenshot = false;
		File.Move(screenshotName, filePath);
        ReactivateObjects(GameObjects);
		ReactivateObjects(UIObjects);
	}
	
	//for mobile devices
	public void _CaptureScreenshot()
	{
        if (saveToGallery)
        {
			takingScreenshot = true;
			StartCoroutine(TakeScreenshotAndSave());
		}
		if (share)
        {
			takingScreenshot = true;
			StartCoroutine(TakeScreenshotAndShare());
		}
	}

	private IEnumerator TakeScreenshotAndSave()
	{
		DeactivateObjects(GameObjects);
		DeactivateObjects(UIObjects);
		yield return new WaitForEndOfFrame();
		//takingScreenshot = false;
		//yield return null;
		Texture2D ss = new Texture2D(Screen.width, Screen.height, TextureFormat.RGBA64, false);
		takingScreenshot = false;
		ss.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
		ss.Apply();
		string name = string.Format(System.DateTime.Now.ToString("yyyy-MM-dd-HHmmss-fff"));
		Debug.Log("Permission result: " + NativeGallery.SaveImageToGallery(ss,folderName, screenshotName+name));

		Debug.Log("screenshot clicked");
		
		ReactivateObjects(GameObjects);
		ReactivateObjects(UIObjects);

	}
	public string TruncateString(string input, int maxLength)
	{
		if (input.Length <= maxLength)
		{
			return input;
		}
		else
		{
			return input.Substring(0, maxLength);
		}
	}
	private void OnGUI()
	{
		if (takingScreenshot && watermark)
		{
			// Show the screenshot texture
			GUI.DrawTexture(new Rect(0, 0, Screen.width, Screen.height), screenshotTexture);

			GUI.color = Color.white;

			float diagonalAngle = Mathf.Atan2(Screen.height, Screen.width) * Mathf.Rad2Deg;

			// Rotate the GUI matrix around the center of the screen
			GUIUtility.RotateAroundPivot(-diagonalAngle, new Vector2(Screen.width * 0.5f, Screen.height * 0.5f));

			// Show the watermark text
			GUIStyle style = new GUIStyle();
			style.normal.textColor = new Color(0f, 0f, 0f, 0.25f); // White with 50% transparency
			style.fontSize = 150; // Adjust the font size as needed
			style.alignment = TextAnchor.MiddleCenter;
			Debug.Log("screenshot GUI method");
			GUI.Label(new Rect(0, 0, Screen.width, Screen.height), TruncateString(watermarkText, numberOfCharsAllowed), style);

			// Reset the GUI matrix rotation
			GUIUtility.RotateAroundPivot(diagonalAngle, new Vector2(Screen.width * 0.5f, Screen.height * 0.5f));
			//takingScreenshot = false;
		}
	}
	private IEnumerator TakeScreenshotAndShare()
	{
		DeactivateObjects(GameObjects);
		DeactivateObjects(UIObjects);
		yield return new WaitForEndOfFrame();

		Texture2D ss = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);
		ss.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
		ss.Apply();

		string filePath = Path.Combine(Application.temporaryCachePath, "shared img.png");
		File.WriteAllBytes(filePath, ss.EncodeToPNG());

		// To avoid memory leaks
		Destroy(ss);

		new NativeShare().AddFile(filePath)
			//.SetSubject("Subject goes here").SetText("Hello world!").SetUrl("https://github.com/yasirkula/UnityNativeShare")
			.SetCallback((result, shareTarget) => Debug.Log("Share result: " + result + ", selected app: " + shareTarget))
			.Share();
		ReactivateObjects(GameObjects);
		ReactivateObjects(UIObjects);
	}
}
