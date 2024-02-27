using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
public class StaticVariable : MonoBehaviour
{
    
    public static int var;
    public const int var_2=0;
    private const string sceneName = "StaticVarTest";
    public ItemsDataHolder itemDataHolder;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("the value of static variable is "+var);
        Debug.Log("the value of const variable is " + var_2);
    }
    // Update is called once per frame
    void Update()
    {
        ButtonClick();
    }
    public void ButtonClick()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            var = 1;
            SceneHandler.Instance.ChangeScene(itemDataHolder.dataholder.sceneName);
            itemDataHolder.damageRate = 20;
            Debug.Log("Space button is pressed down");
        }
    }
}
