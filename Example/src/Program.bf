using Steak.DependencyInjection;
using System;

namespace Example
{
	class Program
	{
		static void Main()
		{
			Container container = scope Container();
			container.RegisterSingleton<Application>();
			container.RegisterSingleton<ILogger, Logger>();
			container.RegisterScoped<IBusinessLogic, BusinessLogic>();
			
			Application app = container.Resolve<Application>();
			app.Run();

			Console.Read();
		}
	}

	[Dependency]
	public class Application
	{
		public ILogger Logger;
		public IBusinessLogic Logic ~ delete _;

		public this(ILogger logger, IBusinessLogic logic)
		{
			Logger = logger;
			Logic = logic;
		}

		public void Run()
		{
			Logger.Log("Running");
			Logic.DoBusiness();
			Logger.Log("Done");
		}
	}

	public interface ILogger
	{
		public void Log(StringView format, params Object[] args);
	}

	[Dependency]
	public class Logger : ILogger
	{
		public void Log(StringView format, params Object[] args)
		{
			Console.WriteLine(format, params args);
		}
	}

	public interface IBusinessLogic
	{
		public void DoBusiness();
	}

	[Dependency]
	public class BusinessLogic : IBusinessLogic
	{
		public ILogger Logger;

		public this(ILogger logger)
		{
			Logger = logger;
		}

		public void DoBusiness()
		{
			Logger.Log("Doing business");
		}
	}
}
