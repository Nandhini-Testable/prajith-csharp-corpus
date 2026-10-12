using System.Diagnostics;
using NUnit.Framework;
using OpenTelemetry;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

namespace OrderKit.Tests
{
    /// <summary>
    /// Wraps the whole test run in one OpenTelemetry trace and ships it over OTLP.
    /// The endpoint comes from OTEL_EXPORTER_OTLP_ENDPOINT; with no collector
    /// listening the export is dropped and the run is unaffected.
    /// </summary>
    [SetUpFixture]
    public class TracingSetup
    {
        public static readonly ActivitySource Source = new ActivitySource("OrderKit.Tests");

        private TracerProvider provider;
        private Activity run;

        [OneTimeSetUp]
        public void Start()
        {
            provider = Sdk.CreateTracerProviderBuilder()
                .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("OrderKit.Tests"))
                .AddSource(Source.Name)
                .AddOtlpExporter()
                .Build();
            run = Source.StartActivity("test-run");
        }

        [OneTimeTearDown]
        public void Stop()
        {
            if (run != null)
            {
                run.Dispose();
            }

            if (provider != null)
            {
                provider.Dispose();
            }
        }
    }
}
