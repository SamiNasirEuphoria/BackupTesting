using UnityEngine;
[CreateAssetMenu(fileName = "ItemsDataHolder", menuName = "CustomScriptableObject/DataItem")]
public class ItemsDataHolder : ScriptableObject
{
    public float speed;
    public int health;
    public int damageRate;
    public DataHolder dataholder;
}
