Here is the revised, detailed plan, now exclusively focused on **Thread Dump Analysis** in Performance Testing, across Java on RHEL and .NET on Windows Azure IaaS, using Git for deployment, and Apache JMeter for load generation. All heap dump-related content has been removed to streamline the session.

---

## Comprehensive Plan: Mastering Thread Dumps in Performance Testing (Java & .NET on Azure IaaS)

**Session Goal:** To empower participants with the knowledge and practical skills to deploy, load test, generate, analyze, and interpret **thread dumps** in both Java and .NET applications on Azure IaaS to diagnose and resolve performance bottlenecks.

**Target Audience:** Performance Testers, Developers, DevOps Engineers.

**Duration:** (Estimate 3.5 - 5 hours for this level of detail and hands-on demonstrations)

**Key Tools:**
*   **Source Control:** GitHub
*   **Azure Infrastructure:** Azure Portal, Azure CLI/PowerShell (for VM setup reference)
*   **Web Application:** Spring Boot (Java), ASP.NET Core (C#)
*   **Application Servers:** OpenJDK/Tomcat (RHEL), IIS/Kestrel (Windows)
*   **Load Testing:** Apache JMeter
*   **Thread Dump Generation:** `jstack` (Java), `dotnet-dump` / Process Explorer (Windows), `gdb` (Linux .NET)
*   **Thread Dump Analysis:** `fastThread.io`, `TDA (Thread Dump Analyzer)`, VisualVM (Java), PerfView (.NET), `dotnet-dump analyze`
*   **Operating Systems:** RHEL (for Java), Windows Server (for .NET)

---

### **Phase 1: Introduction, Setup & Baseline (Approx. 1.5 - 2 Hours)**

1.  **Introduction to Thread Dumps (15 min)**
    *   What is a Thread Dump? (A snapshot of all threads within a JVM or CLR process).
    *   Why are they crucial for Performance Testing? (Diagnosing responsiveness, throughput, resource utilization issues, identifying bottlenecks).
    *   When to take them? (During load, performance degradation, high CPU usage, application unresponsiveness, hangs).
    *   Key Thread States (RUNNABLE, BLOCKED, WAITING, TIMED_WAITING, NEW, TERMINATED in Java; and their CLR equivalents).
    *   **Hands-on Prep:** Briefly show the Git repository structure.

2.  **Azure IaaS VM & Git Setup (60 min - Hands-on for you, viewers observe)**
    *   **GitHub Repository Walkthrough:**
        *   Explain the `java-spring-boot-app` and `dotnet-aspnet-core-app` folders.
        *   Show the code for basic functionality and the placeholder sections for injecting issues.
        *   Briefly cover `Dockerfile` (if using for deployment) or setup scripts.
    *   **Azure VM Provisioning (Conceptual Overview):**
        *   Discuss creating an Azure Windows Server VM (e.g., `performance-win-vm`) and an Azure RHEL VM (e.g., `performance-rhel-vm`).
        *   Briefly mention network security groups (NSGs) for port access (e.g., HTTP/S, SSH/RDP).
        *   *(You would pre-provision these VMs for the session, but conceptually walk through the steps).*
    *   **Application Deployment - Hands-on for you:**
        *   **Connect to RHEL VM (SSH):**
            *   `git clone <your-github-repo-url>`
            *   Navigate to `java-spring-boot-app`.
            *   Install OpenJDK and Maven/Gradle (if not already on base image).
            *   `mvn clean install` (or equivalent build command).
            *   Run the Spring Boot JAR: `java -jar target/your-app.jar &` (explain `&` for backgrounding).
            *   Verify access via `curl localhost:8080/api/fast`.
        *   **Connect to Windows VM (RDP):**
            *   `git clone <your-github-repo-url>`
            *   Navigate to `dotnet-aspnet-core-app`.
            *   Install .NET SDK (if not already on base image).
            *   `dotnet publish -c Release -o C:\app\publish`
            *   Configure IIS to host the published application, or run directly `dotnet C:\app\publish\YourApp.dll` (prefer IIS for realism).
            *   Verify access via browser or `curl http://localhost/api/fast`.

3.  **JMeter Load Test Plan Setup (30 min - Hands-on for you, viewers follow along for their setup)**
    *   **Objective:** Create a basic Test Plan to hit healthy endpoints.
    *   **Your Machine (and Viewer's Machines):**
        *   Launch JMeter.
        *   Create a basic Test Plan.
        *   Add Thread Groups: one for Java app, one for .NET app.
        *   Configure HTTP Request samplers for the `/api/fast` endpoint on both Azure VMs (using their public IPs/DNS names).
        *   Add Listeners: View Results Tree, Summary Report, Aggregate Report, Response Times Graph, Throughput Graph, Errors Graph.
    *   **Hands-on:** You'll build this live, explaining each step. Viewers will replicate on their machines.

4.  **Establish Performance Baseline (15 min - Hands-on for you & viewers)**
    *   **Objective:** Run a light load test on the "healthy" applications to get a baseline for metrics (response time, throughput, errors).
    *   Run JMeter with a small number of users hitting `/api/fast` on both Java and .NET apps.
    *   **Show & Discuss:** Live metrics in JMeter listeners. What does "healthy" look like in terms of these metrics?
    *   **Hands-on:** You'll execute the JMeter test; viewers will run it simultaneously on their own JMeter instances.

---

### **Phase 2: Diagnosing Performance Issues with Thread Dumps (Approx. 2 - 2.5 Hours)**

*(For each issue, you will: 1. Introduce the concept. 2. Implement the issue in both Java and .NET applications (code change + redeploy). 3. Run a JMeter load test and demonstrate performance degradation. 4. Generate thread dumps during the degradation. 5. Analyze the thread dumps using multiple tools to identify the root cause. 6. Fix the issue (code change). 7. Verify the fix with another load test and potentially a thread dump.)*

---

#### **Issue 1: Infinite Loop / High CPU Usage (40 min - Hands-on for you)**

*   **Concept:** A thread consuming excessive CPU cycles due to a non-terminating loop or inefficient computation, leading to overall system slowdown.
*   **Implementation (Hands-on for you - Push to Git, Pull on VMs, Redeploy):**
    *   **Java (RHEL VM):** Implement `/api/infiniteLoop` with `while(true) { /* some minimal work */ }` in Spring Boot.
    *   **.NET (Windows VM):** Implement `/api/infiniteLoop` with `while(true) { /* minimal work */ }` in ASP.NET Core.
*   **Load Test (Hands-on for you & viewers):** Hit the `/api/infiniteLoop` endpoint. Show high CPU usage on respective VMs (via `top` on RHEL, Task Manager on Windows), slow response times, and potential starvation.
*   **Generate Dumps (Hands-on for you):**
    *   **Java (RHEL):** `jstack <pid> > java_highcpu_threaddump.txt` (take 3-5 dumps, 5s apart).
    *   **.NET (Windows):** Use **Process Explorer** -> "Create Full Dump"; or `dotnet-dump collect -p <pid>`.
*   **Analysis (Hands-on for you):**
    *   **Java:**
        *   **fastThread.io:** Upload dumps, identify threads with high CPU-like patterns (same stack trace repeating across dumps).
        *   **TDA:** Load multiple dumps, look for repeating stack frames and the presence of native threads consuming CPU (if configured for native thread IDs).
        *   **VisualVM (Remote):** Connect VisualVM to the Java app (via JMX/SSH tunnel), observe live CPU usage per thread, and take a thread dump from within VisualVM.
    *   **.NET:**
        *   **PerfView (Windows):** Capture CPU usage, drill down into high-CPU threads and their stack traces.
        *   **dotnet-dump analyze:** Load the dump, use `clrstack` or `threads` commands to examine stacks.
*   **Fix & Verify:** Break the loop/optimize. Redeploy. Rerun JMeter.

#### **Issue 2: Deadlock (40 min - Hands-on for you)**

*   **Concept:** Two or more threads waiting indefinitely for each other to release resources, causing a permanent standstill for the affected requests.
*   **Implementation (Hands-on for you - Git, Deploy):**
    *   **Java (RHEL):** Implement `/api/deadlock` using two synchronized blocks or `ReentrantLocks` creating a classic deadlock.
    *   **.NET (Windows):** Implement `/api/deadlock` using `lock` statements or `Monitor` class for a similar deadlock.
*   **Load Test (Hands-on for you & viewers):** Hit the `/api/deadlock` endpoint. Show requests hanging, extremely high response times, no throughput.
*   **Generate Dumps (Hands-on for you):**
    *   **Java (RHEL):** `jstack <pid> > java_deadlock_threaddump.txt` (multiple dumps).
    *   **.NET (Windows):** Use **Process Explorer** / `dotnet-dump collect`.
*   **Analysis (Hands-on for you):**
    *   **Java:**
        *   **fastThread.io:** Explicitly detects and highlights deadlocks in the summary.
        *   **TDA:** Also explicitly detects deadlocks and shows participating threads.
        *   **Raw Dump (briefly):** Show how "Found one Java-level deadlock:" message appears.
    *   **.NET:**
        *   **PerfView:** Can identify blocked threads and potential deadlocks by looking at waiting chains.
        *   **dotnet-dump analyze:** Examine thread stacks using `clrstack` for `System.Threading.Monitor.Enter` or `Wait` calls.
*   **Fix & Verify:** Reorder lock acquisition, use `tryLock` with timeout. Redeploy. Rerun JMeter.

#### **Issue 3: Blocked Threads Waiting on External Resource (e.g., Database, Network Call) (40 min - Hands-on for you)**

*   **Concept:** Threads spending excessive time waiting for an external system (database, another microservice, file I/O), leading to thread pool exhaustion and application unresponsiveness.
*   **Implementation (Hands-on for you - Git, Deploy):**
    *   **Java (RHEL):** Implement `/api/dbCall` or `/api/externalCall` to simulate a 5-second slow external dependency (e.g., `Thread.sleep(5000)` blocking synchronously).
    *   **.NET (Windows):** Implement `/api/dbCall` or `/api/externalCall` using `Task.Delay(5000).Wait()` (synchronous wait) to simulate a slow external call.
*   **Load Test (Hands-on for you & viewers):** Hit the slow endpoint. Show degraded performance, very high response times, and potential thread pool exhaustion.
*   **Generate Dumps (Hands-on for you):**
    *   **Java (RHEL):** `jstack <pid> > java_external_wait_threaddump.txt` (multiple dumps).
    *   **.NET (Windows):** Use **Process Explorer** / `dotnet-dump collect`.
*   **Analysis (Hands-on for you):**
    *   **Java:**
        *   **fastThread.io / TDA:** Look for threads in `BLOCKED` or `WAITING` state on I/O operations (e.g., `SocketInputStream.read`, JDBC driver calls). Identify common stack frames.
        *   **VisualVM:** Observe thread pool usage and states, highlighting threads stuck in specific network/DB calls.
    *   **.NET:**
        *   **PerfView:** Identify threads waiting on network I/O or database calls. Trace back to problematic code.
        *   **dotnet-dump analyze:** Look for `System.Net.Sockets.Socket.Receive` or ADO.NET related calls in stack traces.
*   **Fix & Verify:** Implement asynchronous programming (e.g., `CompletableFuture` in Java, `async/await` in .NET). Redeploy. Rerun JMeter.

#### **Issue 4: Connection Pool Exhaustion (30 min - Hands-on for you)**

*   **Concept:** Application fails to release connections to the database or other resource pools, leading to all available connections being used up. Subsequent requests wait indefinitely for a connection, causing application hangs or timeouts.
*   **Implementation (Hands-on for you - Git, Deploy):**
    *   **Java (RHEL):** Modify `/api/dbCall` to acquire a DB connection but *not* close it (`connection.close()`) in a specific scenario.
    *   **.NET (Windows):** Modify `/api/dbCall` to open a `SqlConnection` but *not* dispose it (`.Dispose()`) or use it in a `using` block.
*   **Load Test (Hands-on for you & viewers):** Hit the `/api/dbCall` endpoint repeatedly. Show eventual errors (connection timeout) or hanging requests due to lack of connections.
*   **Generate Dumps (Hands-on for you):**
    *   **Java (RHEL):** `jstack <pid> > java_conn_pool_threaddump.txt` (multiple dumps).
    *   **.NET (Windows):** Use **Process Explorer** / `dotnet-dump collect`.
*   **Analysis (Hands-on for you):**
    *   **Java:**
        *   **fastThread.io / TDA:** Look for threads in `WAITING` state, specifically waiting for a database connection from a connection pool (e.g., `HikariPool.getConnection`, `TomcatDataSource.getConnection`).
    *   **.NET:**
        *   **PerfView / dotnet-dump analyze:** Look for threads waiting on `System.Data.SqlClient.SqlConnectionFactory.GetConnection` or similar connection acquisition methods, indicating pool starvation.
*   **Fix & Verify:** Ensure proper connection closing/disposing (e.g., `try-with-resources` in Java, `using` blocks in .NET). Redeploy. Rerun JMeter.

---

### **Phase 3: Best Practices & Q&A (Approx. 30 - 45 min)**

1.  **Best Practices for Thread Dump Analysis (20 min - Discussion/Slides):**
    *   **Take Multiple Dumps:** A single dump is often insufficient. Take 3–5 thread dumps at intervals of 5–10 seconds during an issue to observe patterns and state changes.
    *   **Correlate with Logs:** Match stack traces in the dump with application logs (from Azure Log Analytics or file logs) to find problem code and contextual events. Time stamps are crucial here.
    *   **Look for Long-Running/Blocked Threads:** Identify threads stuck on a particular method or resource across multiple dumps.
    *   **Analyze Lock Contention:** Explicitly look for threads in `BLOCKED` state or waiting on monitors, indicating contention for shared resources.
    *   **Monitor System Metrics First:** Use tools like `top`/`htop` (RHEL), Task Manager/Resource Monitor (Windows), `jstat` (Java), or Azure Monitor for a high-level view (CPU, Memory, Disk I/O, Network I/O) before diving into dumps. This helps narrow down the problem area.
    *   **Automate in CI/CD/Monitoring:** Discuss integrating thread dump generation into performance testing pipelines or setting up monitoring alerts to automatically trigger dump collection when performance thresholds are breached.
    *   **Security & Data Privacy:** Briefly discuss the potential for sensitive data (e.g., connection strings, partial request data) to appear in thread dumps and the need for appropriate handling.

2.  **Summary & Q&A (15-25 min - Discussion)**
    *   Recap of all issues and the power of thread dump analysis for performance troubleshooting.
    *   Open floor for questions and discussion on real-world scenarios and challenges.

---

### **Pre-Training Setup Checklist for You:**

1.  **Azure Setup:**
    *   Provision an Azure RHEL VM (`performance-rhel-vm`) with OpenJDK (latest LTS), Maven/Gradle, Git, `jstack`, `gdb` installed. Ensure SSH access is configured.
    *   Provision an Azure Windows Server VM (`performance-win-vm`) with .NET SDK (latest LTS), IIS, Git, `dotnet-dump`, Process Explorer installed. Ensure RDP access is configured.
    *   Configure Network Security Groups (NSGs) on both VMs to allow inbound HTTP/HTTPS traffic from anywhere (for JMeter) and SSH/RDP from your IP.
    *   Note down public IPs/DNS names of both VMs.
2.  **GitHub Repository:**
    *   Create a public GitHub repository.
    *   Push your `java-spring-boot-app` and `dotnet-aspnet-core-app` codebases. Ensure all "problematic" code sections are present but either commented out or controlled by simple feature flags for easy activation during the demo.
3.  **Local Machine Setup:**
    *   Install Java JDK.
    *   Install Apache JMeter.
    *   Install VisualVM.
    *   Install PerfView (Windows only).
    *   Install `TDA (Thread Dump Analyzer)`.
    *   Ensure internet access for `fastThread.io`.
    *   Have SSH client (e.g., Git Bash, PuTTY, WSL) and RDP client ready.
4.  **JMeter Test Plans:**
    *   Create separate JMeter `.jmx` files for each scenario (baseline, infinite loop, deadlock, external wait, connection pool) for both Java and .NET. This allows for quick switching during the demo.
5.  **Practice Runs:**
    *   Crucially, practice the entire flow multiple times: deploying, activating issues, running JMeter, generating dumps, analyzing, fixing, redeploying, and verifying. This will ensure a smooth, impactful session.
6.  **Presentation Material:**
    *   Prepare introductory slides, slides for the best practices section, and a summary slide.

---

This plan is now fully dedicated to thread dump analysis, providing a deep, practical understanding for your viewers on how to troubleshoot performance issues in modern Java and .NET applications deployed in a cloud environment.
