using System;

namespace Steak.DependencyInjection
{
	[AttributeUsage(.Class | .Struct | .Field, ReflectUser=.NonStaticFields | .Methods, AlwaysIncludeUser=.AssumeInstantiated | .IncludeAllMethods)]
	public struct DependencyAttribute : Attribute
	{

	}

	[AttributeUsage(.Constructor, ReflectUser=.Methods)]
	public struct InjectionConstructorAttribute : Attribute
	{

	}
}
