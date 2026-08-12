<?php

namespace App\Tests;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class HomeControllerTest extends WebTestCase
{
    public function testHomePageReturnsOk(): void
    {
        $client = static::createClient();
        $client->request('GET', '/pouet');

        $this->assertResponseStatusCodeSame(200);
        $this->assertStringContainsString(
            'Hello from HomeController',
            $client->getResponse()->getContent()
        );
    }
}