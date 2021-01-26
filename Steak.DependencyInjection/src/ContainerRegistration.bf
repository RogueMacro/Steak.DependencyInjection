using System;

namespace Steak.DependencyInjection
{
	public abstract class ContainerRegistration
	{
		public String Name ~ delete _;
		public Type MappedType;
		public Type RegisteredType;

		public this(StringView name, Type mappedType, Type registeredType)
		{
			Name = new String(name);
			MappedType = mappedType;
			RegisteredType = registeredType;
		}

		public abstract Result<Object> Get(Container container);
	}

	public class SingletonContainerRegistration : ContainerRegistration
	{
		private Result<Object> mSingleton = .Err ~ if (_ case .Ok) delete _.Value;

		public this(StringView name, Type mappedType, Type registeredType) : base(name, mappedType, registeredType)
		{}

		public override Result<Object> Get(Container container)
		{
			if (mSingleton case .Err)
				mSingleton = container.Create(RegisteredType);
			return mSingleton;
		}
	}

	public class ScopedContainerRegistration : ContainerRegistration
	{
		public this(StringView name, Type mappedType, Type registeredType) : base(name, mappedType, registeredType)
		{}

		public override Result<Object> Get(Container container)
		{
			return container.Create(RegisteredType);
		}
	}
}
