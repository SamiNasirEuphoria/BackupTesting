using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterSelectionHandler : MonoBehaviour
{
    private static CharacterSelectionHandler instance;
    public static CharacterSelectionHandler Instance
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
        }else if (instance != this)
        {
            Destroy(this.gameObject);
        }
    }
    public GameObject[] arrayOfPlayers;
    public int startIndex;
    private void OnEnable()
    {
        SetSiblingsIndex(startIndex);
    }
    public void SetSiblingsIndex(int index)

    {
        foreach (GameObject obj in arrayOfPlayers)
        {
            obj.SetActive(false);
        }
        arrayOfPlayers[index].SetActive(true);
    }
}
