# eLog-Pulse
A Ruby on Rails application designed for streamlined issue-reporting engine built for speed. Report, track, and resolve—fast.

## 🛠 Prerequisites
To run this application, you need to have **PostgreSQL (9.3+)** installed.

### Database Driver Installation
Ensure you have the `pg` gem installed:

* **Generic:** `gem install pg`
* **macOS (Homebrew):** `gem install pg -- --with-pg-config=/opt/homebrew/bin/pg_config`
* **Windows:** Install PostgreSQL, add the `/bin` directory to your PATH, and run `gem install pg` (choose the win32 build).

## 🚀 Getting Started
1. **Clone & Install**

```Bash
git clone https://github.com/Minazuki-Labs/elog-pulse.git
cd elog-pulse
bundle install
yarn install
```

2. **Database Setup**

Ensure your PostgreSQL service is running, then run:

```Bash
bin/rails db:prepare
```
3. **Environment Variables**

Copy the example environment file and update your credentials:

```Bash
cp .env.example .env
```

4. **Run the App**
```Bash
bin/dev

```

## 🔐 Deployment
For details regrading deployment of the website into your own server, you may follow the step in the following [guide](https://github.com/Minazuki-Labs/eLog-Pulse/wiki).

## 🤝 Contributing
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.
