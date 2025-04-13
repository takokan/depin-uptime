import React from 'react';
import { Activity, Globe, Shield, Server, Clock, ArrowRight, CheckCircle2 } from 'lucide-react';
import { SignedIn, SignedOut, SignInButton, SignUpButton, UserButton } from '@clerk/nextjs';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 text-white">
      {/* Hero Section */}
      <header className="container mx-auto px-6 py-16">
        <nav className="flex justify-between items-center mb-16">
          <div className="flex items-center space-x-2">
            <Activity className="w-8 h-8 text-emerald-400" />
            <span className="text-xl font-bold">DePIN Monitor</span>
          </div>
          <div className="space-x-8 flex flex-row">
            <a href="#features" className="hover:text-emerald-400 transition-colors">Features</a>
            <a href="#validators" className="hover:text-emerald-400 transition-colors">Validators</a>
            <button className="bg-emerald-500 hover:bg-emerald-600 px-6 py-2 rounded-lg transition-colors">
              Get Started
            </button>
            <div className='flex items-center space-x-4'>
              <SignedOut>
                <SignInButton />
                <SignUpButton />
              </SignedOut>
              <SignedIn>
                <UserButton />
              </SignedIn>
            </div>
          </div>
        </nav>

        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-6xl font-bold mb-6">
            Decentralized Website Monitoring
            <span className="text-emerald-400"> on the Blockchain</span>
          </h1>
          <p className="text-xl text-gray-300 mb-12">
            Monitor your website uptime with our decentralized network of validators.
            Get real-time alerts and immutable uptime records stored on-chain.
          </p>
          <div className="flex justify-center gap-6">
            <button className="bg-emerald-500 hover:bg-emerald-600 px-8 py-4 rounded-lg text-lg font-semibold flex items-center gap-2 transition-colors">
              Start Monitoring <ArrowRight className="w-5 h-5" />
            </button>
            <button className="border border-gray-500 hover:border-emerald-400 px-8 py-4 rounded-lg text-lg font-semibold transition-colors">
              View Demo
            </button>
          </div>
        </div>
      </header>

      {/* Stats Section */}
      <section className="bg-gray-800/50 py-16">
        <div className="container mx-auto px-6">
          <div className="grid grid-cols-4 gap-8">
            {[
              { value: '99.99%', label: 'Average Uptime' },
              { value: '1,000+', label: 'Websites Monitored' },
              { value: '150+', label: 'Active Validators' },
              { value: '<10s', label: 'Alert Time' },
            ].map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-4xl font-bold text-emerald-400 mb-2">{stat.value}</div>
                <div className="text-gray-400">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="container mx-auto px-6 py-24">
        <h2 className="text-4xl font-bold text-center mb-16">Why Choose DePIN Monitor?</h2>
        <div className="grid grid-cols-3 gap-12">
          {[
            {
              icon: <Globe className="w-12 h-12 text-emerald-400" />,
              title: 'Global Coverage',
              description: 'Monitor from multiple locations worldwide through our decentralized validator network'
            },
            {
              icon: <Shield className="w-12 h-12 text-emerald-400" />,
              title: 'Immutable Records',
              description: 'All uptime data is stored on-chain, providing transparent and tamper-proof monitoring'
            },
            {
              icon: <Clock className="w-12 h-12 text-emerald-400" />,
              title: 'Real-time Alerts',
              description: 'Instant notifications when your website goes down or experiences issues'
            },
          ].map((feature, index) => (
            <div key={index} className="bg-gray-800/30 p-8 rounded-xl">
              <div className="mb-6">{feature.icon}</div>
              <h3 className="text-xl font-semibold mb-4">{feature.title}</h3>
              <p className="text-gray-400">{feature.description}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Validator Section */}
      <section id="validators" className="bg-gray-800/50 py-24">
        <div className="container mx-auto px-6">
          <h2 className="text-4xl font-bold text-center mb-16">Our Validator Network</h2>
          <div className="grid grid-cols-2 gap-12 items-center">
            <div>
              <h3 className="text-2xl font-semibold mb-6">Become a Validator</h3>
              <ul className="space-y-4">
                {[
                  'Earn rewards for monitoring websites',
                  'Help secure the decentralized network',
                  'Simple setup process',
                  'Automated payouts',
                ].map((item, index) => (
                  <li key={index} className="flex items-center gap-3">
                    <CheckCircle2 className="w-6 h-6 text-emerald-400" />
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
              <button className="mt-8 bg-emerald-500 hover:bg-emerald-600 px-8 py-4 rounded-lg text-lg font-semibold flex items-center gap-2 transition-colors">
                Join as Validator <Server className="w-5 h-5" />
              </button>
            </div>
            <div className="bg-[url('https://images.unsplash.com/photo-1451187580459-43490279c0fa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80')] 
                        bg-cover bg-center rounded-xl h-96"></div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 py-12">
        <div className="container mx-auto px-6">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-2">
              <Activity className="w-6 h-6 text-emerald-400" />
              <span className="text-lg font-bold">DePIN Monitor</span>
            </div>
            <div className="text-gray-400">
              © 2025 DePIN Monitor. All rights reserved.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
