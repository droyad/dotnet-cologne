using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Hello
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json");

            var configuration = builder.Build();

            app.Run(async (context) =>
            {
                var name = configuration["name"];
                var machine = configuration["machine"];
                var deployment = configuration["macdeploymenthine"];
                context.Response.ContentType = "text/plain; charset=utf-8";
                await context.Response.WriteAsync($"Griaß di {name} und Köln\r\nI am running on {machine}\r\nVersion {typeof(Startup).Assembly.GetName().Version}\r\nDeployment {deployment}", Encoding.UTF8);
            });
        }
    }
}