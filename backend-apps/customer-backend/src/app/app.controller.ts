import { Controller, Get } from '@nestjs/common';
import { backendervice } from './app.service';

@Controller()
export class AppController {
  constructor(
    private readonly backendervice: backendervice,
  ) {}

  @Get()
  getData() {
    return this.backendervice.getData();
  }

  @Get('health')
  getHealth() {
    return { 
      status: 'ok', 
      timestamp: new Date().toISOString(), 
      message: 'HOT RELOAD IS WORKING PERFECTLY!',
      version: '3.0',
      test: 'Changes are detected and applied automatically!',
      docker: 'File watching in Docker is now working!'
    };
  }

  
}
