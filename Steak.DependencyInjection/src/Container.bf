using System;
using System.Collections;
using System.Reflection;

namespace Steak.DependencyInjection
{
	public class Container : IDisposable
	{
		private bool mIsDisposed = false;

		private List<ContainerRegistration> mRegistrations = new .();
		public List<ContainerRegistration> Registrations => mRegistrations;

		public void RegisterSingleton<TInterface, TImplementation>(StringView name = "") => Registrations.Add(new SingletonContainerRegistration(name, typeof(TInterface), typeof(TImplementation)));
		public void RegisterSingleton<T>(StringView name = "") => Registrations.Add(new SingletonContainerRegistration(name, typeof(T), typeof(T)));

		public void RegisterScoped<TInterface, TImplementation>(StringView name = "") => Registrations.Add(new ScopedContainerRegistration(name, typeof(TInterface), typeof(TImplementation)));
		public void RegisterScoped<T>(StringView name = "") => Registrations.Add(new ScopedContainerRegistration(name, typeof(T), typeof(T)));

		public bool IsRegistered<T>() => IsRegistered(typeof(T));
		public bool IsRegistered<T>(StringView name) => IsRegistered(typeof(T), name);

		public ~this()
		{
			Dispose();
		}

		public bool IsRegistered(Type type)
		{
			for (var registration in Registrations)
			{
				if (registration.MappedType == type)
					return true;
			}

			return false;
		}

		public bool IsRegistered(Type type, StringView name)
		{
			for (var registration in Registrations)
			{
				if (registration.MappedType == type && registration.Name == name)
					return true;
			}

			return false;
		}

		public Result<T> Resolve<T>()
		{
			var object = Try!(Resolve(typeof(T)));
			return (T) object;
		}

		public Result<T> Resolve<T>(StringView name)
		{
			var object = Try!(Resolve(typeof(T), name));
			return (T) object;
		}

		public Result<Object> Resolve(Type type)
		{
			for (var registration in Registrations)
			{
				if (registration.MappedType == type)
					return Try!(registration.Get(this));
			}

			return .Err;
		}

		public Result<Object> Resolve(Type type, StringView name)
		{
			for (var registration in Registrations)
			{
				if (registration.MappedType == type && registration.Name == name)
					return Try!(registration.Get(this));
			}

			return .Err;
		}

		public Result<T> Create<T>()
		{
			var object = Try!(Create(typeof(T)));
			return (T) object;
		}

		public Result<Object> Create(Type type)
		{
			var methods = type.GetMethods();
			MethodInfo injectionCtor = ?;
			bool isFirstConstructor = true;
			bool isConstructor = false;

			for (var method in methods)
			{
				if (!method.IsConstructor)
					continue;

				isConstructor = true;

				if (isFirstConstructor)
				{
					injectionCtor = method;
					isFirstConstructor = false;
				}
				else if (injectionCtor.ParamCount == 0)
				{
					injectionCtor = method;
				}
				else if (method.GetCustomAttribute<InjectionConstructorAttribute>() case .Ok)
				{
					injectionCtor = method;
					break;
				}
			}

			if (!isConstructor)
				return .Err;

			if (injectionCtor.ParamCount == 0)
				return Try!(type.CreateObject());

			Variant[] parameters = scope Variant[injectionCtor.ParamCount];

			for (int i = 0; i < injectionCtor.ParamCount; i++)
			{
				var paramType = injectionCtor.GetParamType(i);
				var dep = Try!(Resolve(paramType));
				var variant = Variant.Create(paramType, &dep);
				parameters[i] = variant;
			}

			var object = Variant.Create(Try!(type.CreateObject()));
			injectionCtor.Invoke(object, params parameters);
			return object.Get<Object>();
		}

		public void Dispose()
		{
			if (!mIsDisposed)
			{
				DeleteContainerAndItems!(mRegistrations);
				mIsDisposed = true;
			}
		}
	}
}
