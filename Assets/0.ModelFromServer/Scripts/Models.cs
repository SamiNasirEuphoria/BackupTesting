using UnityEngine;
using UnityEngine.UI;
[RequireComponent(typeof(Button))]
public class Models : MonoBehaviour
{
    public string fileName, URL ;
    public Image buttonImage;
    public Button downloadButton;
    private Button myButton;
    public Text loadingText;
    public GameObject parentObject;
    [Header("Keep it sequential")]
    public int index;
    private void Start()
    {
        myButton = this.GetComponent<Button>();
        myButton.onClick.AddListener(ButtonClickHandler);
        CallToLoadModel();
        downloadButton.onClick.AddListener(DownloadModel);
    }
    public void ButtonClickHandler()
    {
        CharacterSelectionHandler.Instance.SetSiblingsIndex(index);
    }
    public void CallToLoadModel()
    {
        if (ModelLoader.Instance.CheckForFileInFolder(fileName))
        {
            Debug.Log("File Founded in directory");
            downloadButton.gameObject.SetActive(false);
            ModelLoader.Instance.StartCoroutine(ModelLoader.Instance.LoadZipFile(fileName, parentObject));
        }
        else
        {
            myButton.interactable = false;
            downloadButton.gameObject.SetActive(true);
            Debug.Log("File not Founded in directory");
            buttonImage.sprite = UIReferenceContainer.Instance.lockImage;
        }
    }
    public void DownloadModel()
    {
        downloadButton.interactable = false;
        loadingText.text = "Loading...";

        ModelLoader.Instance.StartCoroutine(ModelLoader.Instance._DownloadZipFile(fileName, URL, loadingText, buttonImage, parentObject, myButton));
    }
}
