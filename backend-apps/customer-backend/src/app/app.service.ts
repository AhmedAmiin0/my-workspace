import { Injectable } from '@nestjs/common';

@Injectable()
export class backendervice {
  getData(): { message: string } {
    return { message: 'Hello API' };
  }
}
