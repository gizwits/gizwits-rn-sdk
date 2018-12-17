using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Gizwits.Rn.Sdk.RNGizwitsRnSdk
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNGizwitsRnSdkModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNGizwitsRnSdkModule"/>.
        /// </summary>
        internal RNGizwitsRnSdkModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNGizwitsRnSdk";
            }
        }
    }
}
