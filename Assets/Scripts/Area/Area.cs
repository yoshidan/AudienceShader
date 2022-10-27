using Unity.Mathematics;
using UnityEngine;
using Random = UnityEngine.Random;

public abstract class Area : MonoBehaviour
{
        public int count;

        protected Vector3 center;
        
        protected Quaternion rotation;

        public abstract Vector3 position();
        

        private void Awake()
        {
            var t = transform;
            center = t.position;
            rotation = t.rotation;
        }
}


